---
title:      Integral of the Inverse Tangent
date:       2013-10-21
summary:    Never forget that everything is implicitly multiplied by one.
---

Textbooks have a habit of throwing the most innocuous looking things at you, but it’s really quite an exercise to figure it out. In the section on Integration by Parts, particularly the section of exercises which only requires a single use of Integration by Parts.

<!--more-->

$$\int\tan^{-1}x\,dx$$

Normally when integrating by parts, you deal with something in the form of $$f(x)\cdot g(x)$$, so to see something not in that form was a little unnerving. Except, then I realized it was in that form, because it’s really $$1\cdot\tan^{-1}x$$. With this in mind, I gave it a go. I picked $$\tan^{−1}x$$ for $$u$$, largely because I can derive that using a formula.

$$\begin{array}{cl}
\int\tan^{-1}\,dx&=x\tan^{-1}x-\int\frac{x}{1+x^2}\,dx\\
\begin{align}
u&=\tan^{-1}x&dv&=dx\\
du&=\frac{1}{1+x^2}\,dx&v&=x
\end{align}
\end{array}$$

Now I’ll be perfectly frank, I am not a smart man, and I stared at $$\frac{x}{1+x^2}$$ far longer than I should have. What is the first thing you attempt when integrating? That lovely reversal of the chain rule, called *u substitution*. I actually had to call over Rob the Professor and he patiently waited for me to talk myself through the process until I saw it. If $$u$$ is set to be $$1+x^2$$, then everything works out smashingly.

$$\begin{array}{cll}
\int\frac{x}{1+x^2}\,dx&=\int\frac{x}{2xu}\,du&=\int\frac{1}{2}\cdot\frac{1}{u}\,du\\
\begin{align}
u&=1+x^2\\
du&=2x\,dx\Rightarrow dx=\frac{1}{2x}\,du
\end{align}
\end{array}$$

Most will flinch at the middle step, but I felt it instructive to illustrate that the $$x$$ in the numerator cancels with the term in the denominator, which leaves the entire expression in terms of $$u$$. I’ve kept the constant separate as well, because the integral of $$\frac{1}{u}$$ should be quite obvious, which will make the following step seem elementary.

$$
\int\frac{1}{2}\cdot\frac{1}{u}\,du=\frac{1}{2}\ln\left|u\right|
$$

Finally, we reset the expression to be in terms of $$x$$:

$$
\frac{1}{2}\ln\left|u\right|=\frac{1}{2}\ln\left(1+x^2\right)
$$

The absolute value is unnecessary because a positive constant plus the square of any number must be positive. When this expression is subtracted from the original leading term, we arrive at the solution to the integral of the inverse tangent:

$$\int\tan^{-1}x\,dx=x\tan^{-1}x-\frac{1}{2}\ln\left(1+x^2\right)+C$$

*This is a solution for §7.1 Exercise #19 from* Calculus: Early Transcendentals.
