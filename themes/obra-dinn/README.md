## Obra Dinn

A minimalist [Zola][zola] theme based on the 1-bit color design of [*The
Return of the Obra Dinn*][obdn], with layout (loosely) based on the
[Kactus][kact] theme for Jekyll.

This theme is opinionated. These opinions are:

* Syntax highlighting is more trouble than it's worth for web
  presentation. Code listings should be short enough that it shouldn't
matter.
* Comments (disqus, etc) are more trouble than they're worth.
* Serifed fonts rock.
* Social media is more trouble than it's worth. There are no Facebook or
  Twitter buttons here!

That said, many of these opinions are easily broken. If you like the
layout you can definitely use it as a starting point to make it your
own!

## Configuration

You can set these in `config.toml` to control your theme:

* `extra.author` you can set this to control your name as it appears in
  the footer.
* `extra.nav_links` a list of links with to elements, `name` and `href`,
  which you can use to link to arbitrary things like your Github or
specific pages on your site.

The following are configurable blocks you can override by making a file
`templates/base.html`:

    {% extends "obra-dinn/templates/base.html" %}

    {% block pre_head %}
      <!-- use this to drop arbitrary html right before the <head> tag -->
    {% endblock %}

    {% block extra_head %}
      <!-- use this to add content to the <head> tag -->
    {% endblock %}

    {% block footer %}
      <!-- use this to override the default footer entirely -->
    {% endblock %}

Additionally the 1-bit color choices can be controlled by SCSS variables
in `sass/site.scss`.

## Modification/Licensing

I want you to be able to use this software regardless of who you may be,
what you are working on, or the environment in which you are working on
it - I hope you'll use it for good and not evil! To this end, "Obra
Dinn" is licensed under the [2-clause BSD][2cbsd] license, with other
licenses available by request. Happy coding!

*Note: if you disentangle my personal branding from this theme I'd be extremely interested in putting this into its own repo and take a PR! I'd do it myself but it's not a huge priority for me right now.*

[zola]: https://www.getzola.org/
[obdn]: https://obradinn.com/
[kact]:  http://jekyllthemes.org/themes/kactus/
[2cbsd]: https://opensource.org/licenses/BSD-2-Clause
