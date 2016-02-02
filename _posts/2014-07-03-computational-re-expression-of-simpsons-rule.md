---
title:      Computational Re-expression of Simpson's Rule
date:       2014-07-03 15:26:29
---

Simpson's rule is given (in my textbook) as such:

$$
\int_{a}^{b}f(x)\approx \text{S}(n),2|n
$$

<!--more-->

$$
\text{S}(n)=\left[
f(x_0) + 4f(x_1) + 2f(x_2) + 4f(x_3) + \dots
+ 2f(x_{n-2}) + 4f(x_{n-1}) + f(x_n)
\right ]\frac{\Delta x}{3}
$$

$$
\Delta x=\frac{b-a}{n},x_k=a+k\Delta x,k\in \mathbb{Z}
$$

It becomes difficult to express this in a way that a computer algebra system can assist you when the definition is given in this format. By re-expressing the definition with two summations, however, this becomes much easier to gain computational assistance.

$$
\text{S}(n)=\left[ f(x_0) + 4\sum_{k=1}^{\frac{n}{2}} f(x_{2k-1}) + 2\sum_{k=1}^{\frac{n}{2}-1} f(x_{2k}) + f(x_n) \right ]\frac{\Delta x}{3}
$$

Why my textbook doesn't see fit to explain this is quite beyond my understanding. It illustrates a clever use of summations and expressions in subscripts to achieve "all the odd elements" and "all the even elements," which is a fundamental tool that will enhance a student's abilities in the future.
