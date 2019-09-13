+++
title = "Headfirst into Rust - Throttle and Mutability"
date = 2018-09-01
+++

In the first iteration of my Throttle, I packaged the state of the
throttle into a [`Cell`][rscll] so that an otherwise immutable throttle
could still function.

    pub struct Throttle<TArg> {
      delay_calculator: Box<Fn(TArg, Duration) -> Duration + Send + Sync>,
      state: Cell<ThrottleState>
    }

This has the interesting side effect of making the throttle unsafe in
threaded environments. Two threads could attempt to mutate the state at
the same time, which would have undefined results.

Fishing for opinions, the suggestion to use an [`RwLock`][rwlck] to
control access to the `Cell` came up. The implication being that, if two
threads try to modify the state of a throttle at the same time, then the
second thread to do so will spin wait until the throttle becomes
available again. This is acceptable behavior, since the throttle may
just wait that thread again anyway as soon as it acquires the lock.

Looking at `RwLock`, however, it is not a happy story. Getting a lock
may fail and that requires propagating that failure to the caller. This
would make the implementation for acquire look something like the
following:

    impl <TArg> Throttle<TArg> {
      pub fn acquire(&self, arg: TArg): LockResult { ... }
    }

Callers would have to match on the result or call `unwrap` on the result
to determine if there was an error or not, which is more complicated
than I want the API to be in its most basic case.

In my opinion, how to handle concurrency failures is not a concern of
the throttle, so instead I chose to make the throttle itself mutable.

    pub struct Throttle<TArg> {
      delay_calculator: Box<Fn(TArg, Duration) -> Duration + Send + Sync>,
      state: ThrottleState
    }

    impl <TArg> Throttle<TArg> {
      pub fn acquire(&mut self, arg: TArg) { ... }
    }

Rust's borrow checker forces the caller to handle thread safety (or
unsafety), in a way that is most sensible to the caller. In the simple
case: there is only a single thread, so the API remains clean of any
concurrency; in the complex case: the consumer can use whatever
concurrency methods are necessary.

In the future I think it would be wise to refactor this down into a
trait for Throttles, with specializations for different kinds of
throttling - simple throttles, closure-controlled throttles, threadsafe
closure-controlled throttles, throttle-buckets, threadsafe throttle
buckets, and so on. But as I iteratively dive deeper into the Rust
language, such things are fun thoughts that can stand to be pondered a
while longer.

[rscll]: https://doc.rust-lang.org/std/cell/
[rwlck]: https://doc.rust-lang.org/std/sync/struct.RwLock.html#method.write
