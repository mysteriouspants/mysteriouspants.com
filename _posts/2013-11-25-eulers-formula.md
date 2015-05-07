---
layout:     theme:post
title:      Euler's Formula, or a Study in Cool
date:       2013-11-25
summary:    In fine, the relationship between trigonometric transcendentals and exponentiation can be said to be imaginary!
---

Let $$i=\sqrt{-1}$$, and let
$$e^{x}=\sum_{k=0}^{\infty}\frac{x^{k}}{k!}$$.[^1] If follows that

$$
e^{ix}=\sum_{k=0}^{\infty}\frac{\left(ix\right)^{k}}{k!}.
$$

<!--more-->

Utilizing series expansion, this can be equivalently expressed this as

$$
\begin{array}{l}
=1+ix+\frac{\left(ix\right)^{2}}{2!}+\frac{\left(ix\right)^{3}}{3!}+\frac{\left(ix\right)^{4}}{4!}+\frac{\left(ix\right)^{5}}{5!}+\frac{\left(ix\right)^{6}}{6!}+\frac{\left(ix\right)^{7}}{7!}+\frac{\left(ix\right)^{8}}{8!}+\cdots\\
=1+ix-\frac{x^{2}}{2!}-\frac{ix^{3}}{3!}+\frac{x^{4}}{4!}+\frac{ix^{5}}{5!}-\frac{x^{6}}{6!}-\frac{ix^{7}}{7!}+\frac{x^{8}}{8!}+\cdots
\end{array}.
$$

Because the series is absolutely convergent, the terms can be rearranged so to be expressed as

$$
\begin{array}{l}
=\left(1-\frac{x^2}{2!}+\frac{x^4}{4!}-\frac{x^6}{6!}+\frac{x^8}{8!}-\cdots\right)+i\left(x-\frac{x^3}{3!}+\frac{x^5}{5!}-\frac{x^7}{7!}+\cdots\right)\\
=\sum_{k=0}^{\infty}\frac{\left(-1\right)^k x^{2k}}{\left(2k\right)!}+i\sum_{k=0}^{\infty}\frac{\left(-1\right)^k x^{2k+1}}{\left(2k+1\right)!}
\end{array}.
$$

By recognizing the Maclaurin series for $$\cos x$$ and $$\sin x$$,[^2] we can collapse the series to

$$
e^{ix}=\cos x+i\sin x.
$$

This is called Euler's Formula,[^3] and perhaps one of the coolest things I've seen in mathematics. It establishes a relationship between exponentiation ($$e^x$$) and trigonometric functions - even if it is just imaginary.

[^1]: [Wikipedia, "List of mathematical series, Exponential function."](http://en.wikipedia.org/wiki/List_of_mathematical_series#Exponential_function)
[^2]: [Wikipedia, "List of mathematical series, Trigonometric, inverse trigonometric, hyperbolic, and inverse hyperbolic functions."](http://en.wikipedia.org/wiki/List_of_mathematical_series#Trigonometric.2C_inverse_trigonometric.2C_hyperbolic.2C_and_inverse_hyperbolic_functions)
[^3]: [Wikipedia, "Euler's formula."](http://en.wikipedia.org/wiki/Euler%27s_formula)
