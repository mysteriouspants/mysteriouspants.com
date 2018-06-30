---
title:    Ceci n'est pas un pipe
date:     2013-10-23
summary:  When integrating a three-symbol term, trigonometry comes to the rescue!
---

Today in Calculus II:

$$\int x\sin x\cos x\,dx$$

<!--more-->

You’ll notice that there’s three symbols in this term, which makes integration by parts impossible. But there’s not actually three symbols there. No, [like Magritte before me](http://en.wikipedia.org/wiki/The_Treachery_of_Images), I must tell you that this is not a pipe – or in this case a three-symbol term. It’s actually a very compact little two-symbol term.

Let me remind you of the Double-Angle Formula:

$$\sin 2\theta=2\sin\theta\cos\theta$$

Therefore, we could easily rewrite that to be just as true:

$$\frac{1}{2}\sin2\theta=\sin\theta\cos\theta$$

This is easily accomplished using integration by parts, which seems to be my theme for this month.

$$\begin{array}{cl}
\int\frac{1}{2}x\sin2x\,dx&=\frac{1}{2}\left[\frac{1}{2}x\cos2x-\int\frac{-1}{2}\cos2x\,dx\right]\\
\begin{aligned}
u&=x&dv&=\sin2x\,dx\\
du&=dx&v&=\frac{-1}{2}\cos2x
\end{aligned}
\end{array}$$

The remainder of which is easily integrated and simplified.

$$\begin{aligned}
\frac{1}{2}\left[\frac{1}{2}x\cos2x-\int\frac{-1}{2}\cos2x\,dx\right]&=\frac{1}{2}\left[\frac{-1}{2}x\cos2x+\frac{1}{4}\sin2x\right]\\
&=\frac{1}{8}\sin2x-\frac{1}{4}x\cos2x+C\end{aligned}$$

*This is a solution for §7.1 Exercise #21 from* Calculus: Early Transcendentals.
