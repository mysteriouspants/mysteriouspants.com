---
title:    Deploying Elixir/Phoenix
date:     2016-07-18 16:38
---

Well 314, it has been a while, has it not? I have recently completed a bit of an adventure (or completed the adventure nearly enough to share, at any rate). I've gone and fallen in love with the [Elixir programming language][elixir0], and the star of the Elixir world right now is [Phoenix][phoenix0], a web framework. Now, cutting websites it's nearly as sexy as it was in the late nineties, but this nearly makes up for it.

Phoenix's one-two punch of a Rails-ish paradigm and a nice database layer in Ecto makes it a true joy to work with. Where Phoenix gains on Rails, however, is in Elixir, a language which keeps much of the happiness of Ruby while handing you the speed of Erlang. Even on database-backed pages Phoenix returns pages in tens of milliseconds.

So it's some hot stuff, and it makes me happy. But with all web apps, there comes a time when running it on my laptop is not enough. So I embarked upon a journey to learn to deploy Elixir/Phoenix apps to a server using [edeliver][edeliver0] and exrm.

---

The overall model of deployment is to commit and push code to your source repository. edeliver will then pull that to a build server (a server that resembles your production server - in OS and architecture, so you can build a compatible package). On this build server it uses exrm to compile a release (or upgrade, which can patch your running code - pretty dope), and downloads that to your computer. You then upload this package to your production server(s).

These exrm releases themselves are pretty cool. They are self-contained releases, they include an Erlang VM, all the package and dependencies to make your app run. Gone are the days of hammering rubygems.org from three dozen machines every deploy!

For my build server, I simply set up a new user account on my Digital Ocean droplet, running Ubuntu Linux, which runs this site and my IRC bouncer. My production server was similarly yet another account on this server. edeliver, however, supports a plurality of production servers. Cleverly, it uses SSH, so you can use keys to make things happen without a single password getting in the way.

# Setting up a Build Server

SSH to the server as `root` or any `sudo`-capable user.

We'll be using [asdf][asdf0] to manage our development dependencies
(erlang, elixir, and nodejs). This allows us to install a plurality of
versions in case you have to build different projects requiring
different versions from the same build user.

First we'll install some prerequisites via `apt`.

    apt-get install git vim unzip
    apt-get install build-essential autoconf m4 libncurses5-dev
    apt-get install libwxgtk3.0-dev libgl1-mesa-dev libglu1-mesa-dev
    apt-get install libpng3 libssh-dev unixodbc-dev
    update-alternatives --set editor /usr/bin/vim.basic

Now create a build user.

    useradd --shell=/bin/bash build

You should install any applicable SSH key for the `build` user into
`~build/.ssh/authorized_keys` now.

Login as the `build` user now and install asdf and its plugins.

    git clone https://github.com/asdf-vm/asdf.git ~/.asdf
    echo '. $HOME/.asdf/asdf.sh' >> ~/.profile
    echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.profile
    source ~/.profile
    asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
    asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
    asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git

This next step will install the actual tools. This can take a while, so
I suggest separating each command by a comma, then running off to get
something to eat. It can take a moment.

    asdf install erlang 19.0
    asdf install elixir 1.3.1
    asdf install nodejs 6.3.1
    asdf global erlang 19.0
    asdf global elixir 1.3.1
    asdf global nodejs 6.3.1

If this worked, then installing Hex and Rebar will work.

    mix local.hex
    mix local.rebar

Your build server is almost ready to get to work! Create the
`my-app_prod.secret.exs` file, which should follow the following
template.

    vim my-app_prod.secret.exs
      use Mix.Config

      config :my_app, MyApp.Repo,
        adapter: Ecto.Adapters.Postgres,
        username: "u",
        password: "p",
        database: "d",
        hostname: "localhost",
        template: "template0",
        pool_size: 10

I'll leave the configuration of your PostgreSQL server to you - there are plenty of tutorials and how-to's for it. Suffice it to say, you should substitute real values where I have left placeholders.

# Setting up a Production Server

Some of these steps will be identical to the steps performed on the build server. If these servers are the same, you can safely skip the redundant steps.

First, SSH to the new production server as `root` or a `sudo`-capable user. First we'll install Elixir and some Erlang dependencies, as well as PostgreSQL. Again, if this isn't your database host, then you might try omitting some. Also, I'm not too sure if the Erlang dependencies are even necessary. If someone does know, please drop me a message.

    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && dpkg -i erlang-solutions_1.0_all.deb
    apt-get update
    apt-get install elixir postgresql erlang-base-hipe erlang-parsetools
    useradd -s /bin/bash my-app-prod
    mkdir -p ~my-app-prod/.ssh
    # add relevant keys to ~my-app-prod/.ssh/authorized_keys
    chown -R my-app-prod:users ~my-app-prod

On deploy and start the application will be running on port `4001`, so firewall
that sucker up.

    ufw deny 4001

Next configure Nginx to reverse proxy to port `4001`. Be sure to replace the
IP address with the public IP address of your production server.

    vim /etc/nginx/sites-available/my-app.com
      map $http_upgrade $connection_upgrade {
        default upgrade;
        '' close;
      }
      
      server {
        listen 80 http2;
        server_name my-app.com;

        access_log off;

        location / {
          proxy_pass http://127.0.0.1:4001;
          
          include proxy_params;
          
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
        }
      }
    ln -s /etc/nginx/sites-{available,enabled}/my-app.com
    service nginx reload

Finally, set the app to autostart on machine boot. So that random things like
rebooting for a kernel update doesn't leave the app high and dry until someone
pokes you on Slack.

    vim /etc/init.d/my-app-prod.conf
      description "my-app-prod"

      ## Uncomment the following two lines to run the
      ## application as www-data:www-data
      setuid my-app-prod
      setgid my-app-prod

      start on runlevel [2345]
      stop on runlevel [016]

      expect stop
      respawn

      env MIX_ENV=prod
      export MIX_ENV

      ## Uncomment the following two lines if we configured
      ## our port with an environment variable.
      # env PORT=4001
      # export PORT

      env HOME=/home/my-app-prod/my_app
      export HOME

      pre-start exec /bin/sh /home/my-app-prod/my_app/bin/my_app start

      post-stop exec /bin/sh /home/my-app-prod/my_app/bin/my_app stop

# Configuring your Phoenix Project

There isn't a whole lot to do here, but some of these steps are important and missing one can lead to about a day of very confused debugging.

    vim config/prod.exs
      use Mix.Config

      config :my_app, MyApp.Endpoint,
        http: [port: 4001],
        url: [host: "my_app.com", port: 8080],
        cache_static_manifest: "priv/static/manifest.json",
        server: true # DON'T FORGET THIS LINE

      config :logger, level: :info

      import_config "prod.secret.exs"

There will be a mess of comments in there, I haven't explored what they all do yet.

The next file to change is `mix.exs`, which you need to add edeliver to as a dependency.

    vim mix.exs
      # ...

      def application do
        [mod: {MyApp, []},
         applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy,
                        :logger, :gettext, :phoenix_ecto, :postgrex, :edeliver]]
      end

      # ...

      defp deps do
        [{:phoenix, "~> 1.2.0"},
         {:postgrex, ">= 0.11.2"},
         {:phoenix_ecto, "~> 3.0"},
         {:phoenix_html, "~> 2.6.1"},
         {:phoenix_live_reload, "~> 1.0.5", only: :dev},
         {:gettext, "~> 0.11"},
         {:cowboy, "~> 1.0.4"},
         {:edeliver, "~> 1.2.10"}]
      end

You'll notice that we've added edeliver to both applications and deps. Note that there is a release version in this file. You can and should increment that from time to time. It'll show up in your builds - speaking of which, we need to configure edeliver to know about all the work we've just done! Do this by creating an edeliver configuration file, that should look something like this:

    mkdir -p .deliver
    vim .deliver/config
      #!/usr/bin/env bash

      APP="my_app" # name of your release

      # You can experiment around with this to see what you like best.
      # I'm a retard, so I build a lot without incrementing the version
      # number, so I like having the extra info. More disciplined developers
      # can probably forgo that, however.
      AUTO_VERSION="commit-count+branch+git-revision"

      BUILD_HOST="build.my-app.com" # host where to build the release
      BUILD_USER="build" # local user at build host
      BUILD_AT="/home/build/builds/my_app" # build directory on build host

      # I don't use any staging servers, so these are really kind of
      # moot point for me. #YOLO
      STAGING_HOSTS="stage-01.my-app.com"
      STAGING_USER="my-app-stage"
      TEST_AT="/home/my-app-stage"

      PRODUCTION_HOSTS="my-app.com"
      PRODUCTION_USER="my-app-prod"
      DELIVER_TO="/home/my-app-prod"

      # runs the phoenix.digest mix command, which gets rid of a missing
      # manifest file error
      pre_erlang_clean_compile() {
        status "Running phoenix.digest" # log output prepended with "----->"
        __sync_remote " # runs the commands on the build host
          [ -f ~/.profile ] && source ~/.profile # load profile (optional)
          set -e # fail if any command fails (recommended)
          cd '$BUILD_AT' # enter the build directory on the build host (required)
          # prepare something
          mkdir -p priv/static # required by the phoenix.digest task
          # run your custom task
          APP='$APP' MIX_ENV='$TARGET_MIX_ENV' $MIX_CMD phoenix.digest $SILENCE
        "
      }

      # copies the prod.secret.exs file you keep sequestered on your build
      # machine into the build directory.
      pre_erlang_get_and_update_deps() {
        # copy it on the build host to the build directory when building
        local _secret_config_file_on_build_host="/home/build/my-app_prod.secret.exs"
        if [ "$TARGET_MIX_ENV" = "prod" ]; then
          status "Linking '$_secret_config_file_on_build_host' to build config dir"
          __sync_remote "
            ln -sfn '$_secret_config_file_on_build_host' '$BUILD_AT/config/prod.secret.exs'
          "
        fi
      }

# Building and Deploying a Release

All this work, and it boils down to some very simple commands!

    mix edeliver build release

Copy the release tag from the output, and deploy that sucker.

    mix edeliver deploy release to production --version=<<that release tag>>
    mix edeliver start production
    mix edeliver migrate production # runs your database migrations!

---

All that work, but look at what was gained! A very slick deployment process that encourages sustainable versioning. These have been my notes from the adventure, which I hope you benefit from in some way. If you find any error, I encourage you to let me know, preferably by making a [pull request on this file][pr0] with the fix.

Happy coding, 314!

[elixir0]: http://elixir-lang.org/
[phoenix0]: http://www.phoenixframework.org/
[edeliver0]: https://github.com/boldpoker/edeliver
[pr0]: https://github.com/mysteriouspants/mysteriouspants.com/blob/master/_posts/2016-07-18-deploying-phoenix.md
