---
title: "Level up your Crate"
date: 2019-03-27
description: >
  A quick list of things to look at when publishing a new crate to give
  it the widest impact possible.
tags:
  - rust
redirect_from:
    # alias for https://rust.azdevs.org/2019-03-27/
  - /blog/2019/level-up-your-crate/
    # alias from zola site
  - /blog/level-up-your-crate/
---

This is adapted from a talk given on 27 March 2019 at [Desert Rust](https://www.meetup.com/Desert-Rustaceans/), a meetup group of Rust enthusiasts in Mesa, Arizona. If you live in the area or are just visiting during a meetup, please stop by - we'd love to see you there!

---

You probably already know how to make a Rust crate.

    cargo new --lib crate

You've probably written some Rust code in it, code that is good and ought to be shared. You've published it to crates.io, and nothing happened. Nobody appreciated it, why?

When I was a young boy and still foolish, my brother had a soccer (football) coach who would tell him, "if you look good, you play good." In the spirit of that council, I believe that even the best software will be ignored if it's not dressed up to impress.

The following tips can help juice up your crate and help it sell itself to potential users.

The elements of a solid crate, unless you know better ones, are:

* README
* Documentation
* Tests
* Continuous Integration (if applicable)

## README

The README is your 60-seconds in an elevator pitch to your potential user. This is the part of your craft where you should throw modesty to the wind, because this is advertising, and advertising is war.

I organize my README into four parts. Everything else is extraneous and belongs in separate documents. These parts are:

1. What is this? What does it do?
2. How does this work? No, how does it work for me? (Best approached with a short code sample).
3. How do I get it? (This is Rust, so I assume it's a crate).
4. Can I use this? By this I mean licensing - not everybody can use every license of software.

I try to be as customer-centric as possible when writing these. The template for my idea of a perfect README looks like the following:

    vim README.md
    # Crate Name
    Elevator pitch! What does this do, and why is it awesome
    at doing it?
    
    ```
    fn main() {
      println!("Code sample!");
    }
    ```
    
    Elaboration about what this does, with more code samples,
    or a link to a wiki or some other documentation.
    
    # License
    [2-Clause BSD](https://opensource.org/licenses/BSD-2-Clause)

It's short, and it frontloads the most pertinent information to someone who's shopping for crates and may have dozens of tabs open for research.

Remember to add your README to your `Cargo.toml` file so it gets picked up by `cargo build` and shows upon your Crates.io listing page as well, such as with [throttle](https://crates.io/crates/mysteriouspants-throttle)!

    vim Cargo.toml
    [package]
    readme = "README.md"

While it may seem trivial, this is another point of contact to make it easy for potential customers to quickly learn about your crate.

### Badges

Badges are little images which automatically updated and tell consumers information about your crate. By being on Crates.io, you get the these two badges for free,

1. a crates.io current version badge, which looks like <img src="https://img.shields.io/crates/v/mysteriouspants-throttle.png" style="width: auto;"/>, and
2. a docs.rs current version badge, which looks like <img src="https://docs.rs/mysteriouspants-throttle/badge.svg" style="width: auto;"/>.

Use these badges to link readers on your Github/Gitlab page to crates.io or to docs.rs.

I like to add these to my README directly below the Crate name, but just before the elevator pitch.

    vim README.md
    # Crate name
    
    [![Crates.io][cios]][cio] [![Docs.rs][drss]][]drs
    
    Elevator pitch!
    
    ...
    
    [cio]: https://crates.io/crates/crate-name
    [cios]: https://img.shields.io/crates/v1/crate-name.svg
    [drs]: https://docs.rs/crate-name
    [drss]: https://docs.rs/crate-name/badge.svg
    

You can also add these links to your `Cargo.toml` so they are visible from your Crates.io listing as well.

    vim Cargo.toml
    [package]
    documentation = "https://docs.rs/crate-name"
    repository = "https://github.com/..."

## Documentation

Documentation is what separates code for me from code for you - and code for future me who has forgotten how everything works.

You've probably already worked out that Rust documentation is in CommonMark (or Markdown) format. Docs for ordinary items, such as structs, fields, and functions, are given by three slashes.

    /// Control the rate of novertrunnions.
    pub mut novertrunnion_choke: f32;

Bigger ideas, such as how an entire crate is to be used or a module within that crate, are given by module docs, which use two slashes and a bang!

    //! For a number of years now, work has been proceeding
    //! in order to bring perfection to the crudely conceived
    //! idea of a transmission that would not only supply
    //! ...

## Tests

You probably don't write bugs, but I do, and I try to prove that my code works using tests. Writing good tests is among the harder things to do, and entire books have been written on the subject, so I'll spare you any incomplete thoughts on the subject here.

The default crate template comes with a stub for you to fill in some tests:

    vim src/lib.rs
    ...
    #[cfg(test)]
    mod tests {
      #[test]
      fn it_works() {
        assert!(1 + 1 == 2);
      }
    }

Cargo comes with a built-in test runner, so running those tests is remarkably easy.

    ➜  retry git:(master) ✗ cargo test
        Finished dev [unoptimized + debuginfo] target(s) in 0.02s
         Running target/debug/deps/mysteriouspants_retry-6c4c9e88511db7ca
    
    running 2 tests
    test tests::succeeds_after_two_retries ... ok
    test tests::fails_after_exhausting_retries ... ok
    
    test result: ok. 2 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
    
       Doc-tests mysteriouspants-retry
    
    running 0 tests
    
    test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

Going further, we arrive at my favorite Rust feature, the part that I think takes Rust from a toy language to something capable of building durable software: doctests.

`cargo test` will try to run code samples in your documentation, so if you change your crate's implementation, you can easily catch idiosyncrasies in your documentation's code examples. This encourages you to document using prose *and* code, creating APIs with rich reference material.

    /// The main winding was of the normal lotus-o-delta type
    /// placed in pandndermic semi-boloid slots of the stator,
    /// ...
    ///
    /// ```rust
    /// # extern crate mysteriouspants_rockwell;
    /// # use rockwell::TurboEncabulator;
    /// # fn main() {
    /// // create a new TurboEncabulator
    /// let mut encabulator = TurboEncabulator {
    ///   cardinal_grammeters: 3
    /// };
    /// assert_eq!(encabulator.cardinal_grammeters, 3);
    /// # }

Any code sample line that does not begin with a `#` (octothorpe) will appear in your documentation, letting you de-noise what shows up on docs.rs.

## Travis

The last thing I look for in a well-constructed crate meant for third-party consumption is some kind of Continuous Integration. For Open-Source, the easiest I know of it [Travis CI](https://travis-ci.org).

Tell Travis how to build your Crate by telling it that you're writing Rust in a `.travis.yml` file.

    vim .travis.yml
    language: rust
    rust:
      - stable
      - beta
      - nightly
    matrix:
      allow_failures:
        - rust: nightly
    fast_finish: true

Using Travis gets you another badge for your README, as well.

    vim Cargo.toml
    [badges]
    travis-ci = { repository = "github-user/repo" }
    
    vim README.md
    [other badges from before] [![Build Status][traviss]][travis]
    
    ...
    
    [travis]: https://travis-ci.org/github-user/repo
    [traviss]: https://travis-ci.org/github-user/repo.svg?branch=master

---

If you've followed these suggestions, I consider your crate as having leveled up! Potential users can

- see what your crate is about at a glance in your README, both on your repo page and on crates.io,
- read detailed documentation and examples to confirm that what you've written is what they're after, and
- see that your code does everything you say that it does with a passing CI build!

---

*These suggestions are* unless you know better ones. *If you do, please open an issue or PR on [github](https://github.com/mysteriouspants/mysteriouspants.com) and be clear it's this post you think ought to be revised.*