+++
title = "Developing a Discord Bot Over a (Long) Weekend"
date = 2020-07-06
+++

Over the extended 4 July weekend I spent some time building a chatbot for
Discord. I, of course, picked Rust, and wanted to record some thoughts and notes
from the experience.

## The Goal

The goal of the bot is to automate some community housekeeping at the
[iDevGames][idg] Discord Server. Particularly we want to experiment with jailing
political discussion to a `#politics` channel so it doesn't disturb those who
don't want to see that discussion. Whenever discussion arises out of that
channel the bot should nudge the participants to take it to the appropriate channel.

That channel is controlled by roles - if you have the role `political animal`
then you can see the `#politics` channel, otherwise it's totally hidden. The bot
should accept requests for that role, both grants and revocation.

## The Crates

I picked the following crates, in alphabetical order:

[`lazy_static`][ciols], which I use in place of a heap-allocated static.

[`regex`][ciorgx], which is incidentally what I like to pretend is a
heap-allocated static.

[`serenity`][cioseren], a client for Discord's API. Much of this post is a
thinly-disguised propaganda work for Serenity - it was really easy to work with,
has a fairly convincing feature set out of the box, and was just generally a
really fun tool to work with. I have some wishlist items that I hope to PR, but
overall a terrific job well done.

[`toml`][ciotoml], which I used for configuration parsing. TOML is simple, this
wasn't a statement on anything other than it was easy to get going and didn't
impede my progress.

## Abstraction

The first major departure from the Serenity example code is that I opted to not
use their Framework. It was rather invested in the notion that bot commands
ought to start with a specific character, such as a bang or a tilde. It had an
escape method which would run on any message, which seemed to me no better than
simply using the ordinary, non-Framework handler.

I ended up [rolling my own][mmh], which works on a command-map pattern with a
slight twist. Each item in the command map is given each message and given the
opportunity to decide whether it wants to act on that message. While there is
not mechanism to stop a handler from performative action in that test, it does
help break up the handler into different functions. I consider it a mild success
in separation of concerns.

## Logic

The logic is broadly separated into three distinct areas of discussion, which
are a command for granting/revoking roles, the use of `to_lowercase/1` to
normalize messages for comparison, and using `contains/2` for detecting those
pesky political words.

The use of a regex is not a particular point of pride. It's a little
prescriptive and I'm not sure it creates a stellar user experience. But it does
work in [`role_wizard.rs`][rw], where it just uses capture groups to structure
input text into the "arguments" of the command. Because I prefer to compile the
regex as few times as possible, this is where I employed `lazy_static`.

A repeated thing is calling `to_lowercase/1` on messages. Internally everything
is lowercase, because Discord can get silly and I don't want to start punching
every possible capitalization of things into my configuration file. I think that
having better case insensitivity options in string operations would make this
perhaps unnecessary. However, it could be just as possible that this could
create many calls to `to_lowercase/1` under the hood, so maybe it's best this
way?

Finally, the distinct reason for this entire adventure (and why the bot exists)
is really to loop through a list of words and find matching ones, then perform
an action on that stimulus. This is [`WordWatcher`][ww]. It's too early in the
bot's lifecycle to say for sure whether this incredibly simplistic approach is
sufficient, however, I suspect that it will be as long as the watch words are
adequate.

## Itches

Throughout development there were a few minor pain points that I think should
have been simple. These range from things that I could submit a PR for to things
that will likely take a PhD researcher some time to determine if an answer can
even be made! In no particular order, these are my itches.

### Getting the current (bot) user name

Getting the bot's user name is surprisingly difficult, to the point that I
looked it up on Discord's site instead of the Serenity API docs to see if it
was even supported. It created some bizarre code that looks like this, from
[`AckMessageHandler`][amh]'s `should_handle/3` method.

```rust
// don't copy-paste this, i learned a better way described below!
if let Ok(current_user) = ctx.http.get_current_user() {
    let user_id = current_user.id;
    
    if msg.mentions_user_id(user_id) {
        return true;
    }
}
```

On the surface now it doesn't look that bad, but determining that the
functionality I wanted was on the `ctx.http` object was a huge leap for me!
Serenity has packaged so much functionality into the thoughtfully-laid-out model
structs that I honestly took `ctx.http` as an internal pointer to pass about on
ceremony and not something that I should be looking at.

I spend perhaps a few hours on that. I'd like to submit a PR which can add a
simple helper to `Message` itself, just a simple one that adds a `mentions_me`
method. I know it would have saved me some time, but I'm fully willing to admit
that I may be on the only person stuck on that.

**Update 2020-07-18**

This was a relatively easy itch to scratch, so I made [a PR][serenpr911] to add
a simple `mentions_me` function to `Message`. A Serenity developer helpfully
pointed out that the means I had been using is *not* cached! To use the cache
collapses this down to a very neat one-liner (if and only if you have the cache
feature enabled).

```rust
msg.mentions_user_id(ctx.cache.read().user.id)
```

Unpacking this a little, `ctx.cache.read()` is because that `cache` is really a
[`CacheRwLock`][CacheRwLock], which itself is a wrapper around an `Arc<RwLock<Cache>>`, which
enables it to be passed around multiple threads.

Calling `read/1` on it is just saying "I only want to read from the cache." This
is rather nifty because it returns a wrapper around the cache, and doesn't lock
the cache for any other readers. Because of RAII semantics, when that wrapper
goes out of scope it gets dropped and that read lock goes away, so someone else
may be able to write to the cache. This is a neat example of how Rust's
ownership model has shepherded us into a safe-by-default idiom when dealing with 
concurrency!

As it so happens, this cache has a pre-cached `CurrentUser`, from which we fetch
the `id` we wanted in the first place. No need for another HTTP call and
possible error to handle from that!

### Getting the current channel name

Getting the current channel id is trivial, but converting that to a name was
surprisingly exciting. Again, from [`AckMessageHandler`][amh], I found it was
easier to convert a list of channel names from configuration to channel ids.

```rust
if let Some(guild_lock) = msg.guild(&ctx.cache) {
    let guild = guild_lock.read();
    let deny_channel_ids: Vec<Option<ChannelId>> =
        self.deny_channels.iter()
        .map(|channel_name|
            guild.channel_id_from_name(&ctx.cache, channel_name)
        ).collect();

    if deny_channel_ids.contains(&Some(msg.channel_id)) {
        return false;
    }
}
```

Now, these are cached locally, so I don't feel too bad about it. But now that
I write this and research again with a bit more experience I find that there's
also [`Guild#channel_id_from_name/3`][cifn]. I would have liked to have seen
a helper method on `Channel` to get the name of it. It would have saved a bit of
time. While this doesn't really solve for really big professional applications
that are designed for connecting to multiple Discord servers at a time, it would
definitely have helped my small hobby project.

### Testing

There are no tests, and of that I am not proud. Some of this is inexperience on
me. Most of my testing experience is with Ruby and Java, both of which are
more dynamic languages and it's fairly easy to mock out parts of a program. I
would really appreciate some way to mock out parts of a program in Rust, as it's
much more relevant for me to test the business logic in my handlers than it is
to create some Rube Goldberg contraption that mimics Discord's official servers!

This is a sticky point that makes me silently kind of wish I had picked Ruby for
this project - but Rust definitely redeems itself on deployment, so stay tuned!

### Configuration parsing

Configuration parsing is super unwrappy. Look at this horrible code I wrote in
[`main.rs`][mrs].

```rust
// this code is kinda unwrappy but I think that's okay because dying in
// initialization is sorta expected on bad config, right?
fn parse_handlers(raw_toml: String) -> Vec<Box<dyn MysteriousMessageHandler>> {
    let toml = raw_toml.parse::<Value>().unwrap();
    let handlers = toml.as_table().unwrap().get("handlers").unwrap().as_array()
        .unwrap();
    ...
```

Now, some of this is on me for insisting on having configuration. This could
have just as easily been handled as code, however, I thought it was better to
have a configuration file that a community member could easily understand and
submit a PR for.

By the comment I was feeling guilty about the `unwrap`s, and rationalized that
unwrapping on service start (where it's immediately obvious and not going to
blow up a running service based on arbitrary user data from Discord) isn't
really a big deal. In other words, it's a code smell, but it's in the kitty
litter box where it belongs.

I chalk this up to some of the immaturity in Rust's error handling. There's a
fair bit of churn between Anyhow and Eyre and the others, and the simple matter
is that effectively modelling errors is hard. I understand that. I'm excited to
see that conversation progress and for this little bit of a cobweb to get
better in the future.

For now, it's just a todo in the back of my head for a lazy Saturday to beat on
this code a little bit to make it less embarrassing.

Speaking of this code, why not Serde? Serde is fantastic, but I rather wanted
something that I had more control over. My background is in Objective-C, where I
got really good with [NSCoder][nscoder] (if I do say so myself). The thing I
really appreciated about `NSCoder` and friends was the control I had over the
serialization and deserialization process. I could branch down a completely
different path on a different serial version id if I really wanted to. It was
all written down and easy to follow. I'd like to see something similar as an
option in Rust, and I'd like to write it. I just need to find the time.

### Ownership and Threading

Right in the header of the [`MysteriousMessageHandler`][mmh] is the constraint
that implementers of this trait must be both `Send` and `Sync`.

```rust
pub trait MysteriousMessageHandler : Send + Sync {
```

I had hoped to avoid that requirement and instead wrap the list of handlers in
`Arc<RwLock<Vec<dyn MysteriousMessageHandler>>>` or otherwise
`Vec<Arc<RwLock<dyn MysteriousMessageHandler>>>` but each incantation I tried
simply would not elide the non-`Send` non-`Sync` nature of the trait. I read the
relevant Rust Book and Rustnomicon pages on the topic, and still couldn't make
it work. I found that frustrating, and would like to correct it in the future
so that future handlers can store whatever data they like. Or perhaps that's a
bad decision on the surface of it, as then handlers will block?

Either way, I spend an hour or two on that little behavior which diverged from
what I thought I read and what I expected. I'd like to revisit that sometime.

## Deployment

The part of this process where I think Rust really shone was in deploying the
bot. In the README I wrote as much, that to deploy you just take the built
binary, `scp` it somewhere, and run it. There's no grand dependency chain from
the OS to worry about, even the TLS layer is handled internally thanks to
RusTLS. I think that's really cool!

Getting it set up to run as a service on my personal server was similarly really
easy, I just used `systemd`. For all it's malignment, this part was delightfully
simple compared to writing a service shell script and managing PID files by
hand. It really was as simple as saying "here's an executable, make sure it's
running as this user after boot."

The deployment instructions are available in the [README][readme], and they're
surprisingly robust for something cobbled together in a few hours.

## Conclusion

Overall I enjoyed the time spend on this little project. I created something
that is useful, and I hope maintainable. Though there were a few sandtraps
along the way, the proof really was in the deployment. Rust created a system
dependency-free binary that idles at about a megabyte and a half of RAM use. For
someone as cost-sensitive as I, that's a win!

If you've got an itch to scratch in Discord that could be served by a Bot, I'd
suggest giving Rust and Serenity a spin. Please make use of my [notes and
code][mysteriousbot] to give yourself a head start, even if that's identifying
dead ends you don't want to go down.

Happy coding!

[idg]: https://www.idevgames.com/
[ciols]: https://crates.io/crates/lazy_static
[ciorgx]: https://crates.io/crates/regex
[cioseren]: https://crates.io/crates/serenity
[ciotoml]: https://crates.io/crates/toml
[mmh]: https://github.com/mysteriouspants/mysteriousbot/blob/caba97f1d219076c28e45f61648e4675e3166a3b/src/mysterious_message_handler.rs
[rw]: https://github.com/mysteriouspants/mysteriousbot/blob/caba97f1d219076c28e45f61648e4675e3166a3b/src/role_wizard.rs
[ww]: https://github.com/mysteriouspants/mysteriousbot/blob/caba97f1d219076c28e45f61648e4675e3166a3b/src/word_watcher.rs
[amh]: https://github.com/mysteriouspants/mysteriousbot/blob/caba97f1d219076c28e45f61648e4675e3166a3b/src/ack_message_handler.rs
[cifn]: https://docs.rs/serenity/0.8.6/serenity/model/guild/struct.Guild.html#method.channel_id_from_name
[mrs]: https://github.com/mysteriouspants/mysteriousbot/blob/caba97f1d219076c28e45f61648e4675e3166a3b/src/main.rs
[nscoder]: https://developer.apple.com/documentation/foundation/nscoder
[readme]: https://github.com/mysteriouspants/mysteriousbot/blob/caba97f1d219076c28e45f61648e4675e3166a3b/README.md
[mysteriousbot]: https://github.com/mysteriouspants/mysteriousbot
[serenpr911]: https://github.com/serenity-rs/serenity/pull/911
[CacheRwLock]: https://docs.rs/serenity/0.8.6/serenity/cache/struct.CacheRwLock.html
