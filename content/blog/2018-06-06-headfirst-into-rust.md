+++
title = "Headfirst into Rust - Building a Throttle"
date = 2018-06-06
+++

This is a development journal of my first Rust crate, [Throttle][glmth], which I built over the course of a weekend and a few weeknights. I based my crate authorship standard on literally a single livecoding session by [Jon "Jonhoo" Gjengset][ytjho], took courage in the Jeremy Clarkson motto "how hard can it be?" and set to the task. The follows how I wrote some really bad code and made a crate.

*Most of the code listings are reconstructions and not completely accurate to what I eventually hammered out which compiled.*

# The Throttle

I decided to build a TPS throttle because I want to build some tooling around Squizz' [zKillboard][zkill] for EVE Online. First of my concerns is that I don't get blocked for spamming his website too much - and to slow down a program I reckon I want a throttle. I started by using the default crate template I got out of IntelliJ, and in the testing section wrote out how I wanted to use the throttle. I got something like the following:

    // simple throttle configured for 10 TPS
    let throttle = Throttle::new(10);

    let iteration_start = Instant::now();

    for _i in 0..11 {
        throttle.acquire();
    }

    // prove that it waited by showing that one second has elapsed
    assert_eq!(iteration_start.elapsed().as_secs() == 1, true);

The basic idea is that by calling `acquire` you're really saying "call `thread::sleep` if and only if I need to slow down," and by making it an object it could even be used by multiple threads of execution at the same time (using a lock). That way multiple threads could be pulling work, and all safely not viciously slaughtering zKillboard.

I started with a perusal of the standard library and found some APIs which will form the backbone of the throttle: [`Duration`][rstdu], [`Instant`][rstin], and [`sleep`][rstsl].

Thus armed, I charged in and created a struct which looked something like the following, and then the first problem happened.

    #[derive(Copy, Clone)]
    enum ThrottleState {
        Uninitialized,
        Initialized {
            previous_invocation: Instant
        }
    }

    pub struct Throttle {
      tps: f32,
      previous_invocation: Cell<ThrottleState>
    }

    impl Throttle {
      fn new(tps: f32) -> Throttle { ... }
      fn acquire(&self) { ... }
    }

Yes, the first problem happened before I had even implemented the methods. My first problem was a single thought:

> wouldn't it be cool if the throttle could be dynamic, getting faster and slower?

I write Java in my day job (trying to transition to Kotlin, but for present purposes the reflex is the same), so the concept of "thing that tells how long to delay" feels like a dependency and should not be an aspect of the `Throttle` itself, and it didn't feel like something that I should slap `Cell<f32>` as the type for `tps` and call it done, either.

Well you say dependency and so I try to make a bean or at least a struct. That was my first problem.

# Storing a Trait, or Don't Write Java in Rust

My first reflex was to create a trait for the thing which controls the variance of the `Throttle`.

    pub Trait DelayCalculator<TArg> {
      fn calculate(arg: TArg) -> Duration;
    }

    impl <TArg> DelayCalculator<TArg> for f32 {
      fn calculate(&self, arg: TArg) -> Duration {
        return Duration::from_millis((1.0 / self) * 1000.0);
      }
    }

So in my head the nifty thing is that now `f32` itself implements `DelayCalculator`, so I should be able to keep my example and pass a straight `f32` into `Throttle::new` and it should *just work.*

But when I modified `Throttle` itself, things broke apart.

    pub struct Throttle<TArg> {
      // ERROR: DelayCalculator is not sized
      delay_calculator: DelayCalculator<TArg>,
      previous_invocation: Cell<ThrottleState>
    }

An experienced Rustacean is likely chuckling a bit, but for the uninitiated, this actually makes a lot of sense only after you stop to consider what you're describing the memory layout to be. To put a `Throttle` somewhere the compiler needs to know how big it is. But a Trait is unsized because it could be implemented by something as small as `u8` or as large as an array of them making a bitmap image of your mom (so filling all addressable memory). There is no way to know.

The compiler helpfully suggests putting the field in a `Box`, or storing it on the heap, so `Throttle` would contain a pointer to allocated memory of any size, which I tried. But it felt wrong. A `Throttle` is simple enough it ought to be expressable without any recourse to the heap!

The next option is to make it a generic parameter, making the `Throttle` look something like the following:

    pub struct Throttle<TDelayCalculator, TArg>
        where TDelayCalculator : DelayCalculator<TArg> {
      delay_calculator: TDelayCalculator,
      previous_invocation: Cell<ThrottleState>
    }

This is better, maybe even good. It makes it harder to work with `Throttle`, however, as you need to know about the `DelayCalculator` it uses to size it and therefore store it. Also a point of detraction, it's heavier. Java-style heavier. It requires the introduction of a new type where perhaps one is unneeded.

Next I decided to try to make it a functional interface.

# Storing a Closure, or Template All The Things

By making the `Throttle` take a delay calculator as a functional interface I hoped to ameilorate the need for making additional implementations like some deranged late nineties Java developer. I also hoped to elide the need for using those `Box`es and generics. This was not to be.

    pub struct Throttle<TArg> {
      // ERROR: Fn<TArg> -> Duration is not sized
      delay_calculator: Fn<TArg> -> Duration,
      previous_invocation: Cell<ThrottleState>
    }

Oops, same errors as before. But it again makes sense. A closure can capture its surrounding state, which means that any closure may have a different size depending on what local state it captured.

So it's back to using a generic:

    pub struct Throttle<TArg, TDelayCalculator> 
        where TDelayCalculator : Fn<TArg> -> Duration {
      delay_calculator: TDelayCalculator,
      previous_invocation: Cell<ThrottleState>,
      delay_arg_type: PhantomData<TArg>
    }

But this simply bubbles the issue of the `TDelayCalculator` being unsizeable back up to the calling code. In the trivial case it doesn't matter because it will live on the stack. But if it's packaged into a client it becomes unergonomic or the whole thing must be `Box`ed. Yuk.

It feels like the `Box` is unavoidable, so for now it's inside the `Throttle` to keep the struct as portable as it possibly can be.

    pub struct Throttle<TArg> {
      delay_calculator: Box<Fn(TArg, Duration) -> Duration>,
      state: Cell<ThrottleState>
    }

This makes the constructors of the struct very simple:

    pub fn new<TDelayCalculator>(delay_calculator: TDelayCalculator) -> Throttle<TArg>
        where TDelayCalculator: Fn(TArg, Duration) -> Duration + 'static {
      return Throttle {
        delay_calculator: Box::new(delay_calculator),
        state: Cell::new(ThrottleState::Uninitialized)
      };
    }

    pub fn new_tps_throttle(tps: f32) -> Throttle<TArg> {
      return Throttle {
        delay_calculator: Box::new(move |_, _|
          Duration::from_millis(((1.0 / tps) * 1000.0) as u64)),
        state: Cell::new(ThrottleState::Uninitialized)
      };
    }

# Documentation that also Tests

Thus far Rust has been delightful. The language is terse, yet expressive, and the compiler, while unforgiving, is helpful with well-written error messages with suggestions to resolution. But perhaps the most impressive to me is how documentation is written for Rust. Beyond a good README file, which has been shown to be the single most important factor in the adoption of an open-source project, the documentation can either be an asset or a liability, depending on the quality and accuracy.

Rust aims to prevent documentation drift by simply compiling it.

The module documentation for Throttle, the top of the package and the introduction when a potential consumer first sees the documentation page, looks like the following:

    //! A simple throttle, used for slowing down repeated code. Use this to avoid
    //! drowning out downstream systems. For example, if I were reading the contents
    //! of a file repeatedly (polling for data, perhaps), or calling an external
    //! network resource, I could use a `Throttle` to slow that down to avoid
    //! resource contention or browning out a downstream service.
    //!
    //! This ranges in utility from a simple TPS throttle, "never go faster than *x*
    //! transactions per second,"
    //!
    //! ```rust
    //! # extern crate mysteriouspants_throttle;
    //! # use std::time::Instant;
    //! # use mysteriouspants_throttle::Throttle;
    //! # fn main() {
    //! // create a new Throttle that rate limits to 10 TPS
    //! let throttle = Throttle::new_tps_throttle(10.0);
    //!
    //! let iteration_start = Instant::now();
    //!
    //! // iterate eleven times, which at 10 TPS should take just over 1 second
    //! for _i in 0..11 {
    //!   throttle.acquire(());
    //!   // do the needful
    //! }
    //!
    //! // prove that it did, in fact, take 1 second
    //! assert_eq!(iteration_start.elapsed().as_secs() == 1, true);
    //! # }
    //! ```

The documentation is itself in CommonMark, so it's remarkably easy to write. But the code sample is compiled, so when I run `cargo test` I see that it runs the documentation code listing as well:

    PS C:\Users\xpm\Projects\mysteriouspants-throttle> cargo test
        Finished dev [unoptimized + debuginfo] target(s) in 0.0 secs
         Running target\debug\deps\mysteriouspants_throttle-62cc10bf6d8c5f7f.exe

    running 1 test
    test tests::it_works ... ok

    test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

       Doc-tests mysteriouspants-throttle

    running 4 tests
    test src\lib.rs -  (line 10) ... ok
    test src\lib.rs -  (line 34) ... ok
    test src\lib.rs - Throttle<TArg>::new_variable_throttle (line 76) ... ok
    test src\lib.rs - Throttle<TArg>::new_variable_throttle (line 92) ... ok

    test result: ok. 4 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out

And to the user, the person viewing the webpage, it looks like any normal code listing.

    // create a new Throttle that rate limits to 10 TPS
    let throttle = Throttle::new_tps_throttle(10.0);

    let iteration_start = Instant::now();

    // iterate eleven times, which at 10 TPS should take just over 1 second
    for _i in 0..11 {
      throttle.acquire(());
      // do the needful
    }

    // prove that it did, in fact, take 1 second
    assert_eq!(iteration_start.elapsed().as_secs() == 1, true);

The combined effect is that I ended up putting more of my tests in the documentation, both as a test-driven measure, and to make sure my tests are really showing how the crate works from a consumer-driven perspective. If I change the API contract, the test should break right in the documentation, so the documentation should not be able to drift away from how the crate actually works, so long as I'm still running the tests.

# Final thoughts

Rust is a language I've had my eye on for a very long time now. It promises to be close to the metal, fast, and expressive, focusing on letting the programmer build abstractions that don't cost in performance as much as possible. It's portable, and it has a great build system with an easy way of taking on new dependencies.

I personally prefer it over more popular modern languages like Go, because Rust dares to ignore the draw of garbage collection to say that the programmer can write proper code with a low water mark in memory (I distrust garbage collectors).

In short, Rust values the things that I value, and for that I enjoy it.

[glmth]: https://github.com/mysteriouspants/throttle
[ytjho]: https://www.youtube.com/watch?v=KS14JIRZTBw
[zkill]: https://www.zkillboard.com/
[rstdu]: https://doc.rust-lang.org/std/time/struct.Duration.html
[rstin]: https://doc.rust-lang.org/std/time/struct.Instant.html
[rstsl]: https://doc.rust-lang.org/std/thread/fn.sleep.html