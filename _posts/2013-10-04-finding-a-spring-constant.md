---
title:      Finding a Spring Constant
date:       2013-10-04
summary:    Hooke's law takes a curious twist!
---

Today in Calculus II I happened upon a curious use of the definite integral in a Physics application, finding a Hooke’s Law spring constant.

<!--more-->

In short, the amount of force $$\text{F}$$ exerted on a spring to stretch it past its equilibrium point can be modeled by $$\text{F}(x)=kx$$, with $$k$$ representing a constant that is specific to each spring. Therefore the amount of work required to move a spring to any point can be modeled as the integral of the force:

$$
\text{W}=\int_a^b\text{F}(x)\,dx
$$

Imagine my surprise when they threw a very different application of the integral at me. And I quote the book:

> **21. Additional stretch** It takes 100 J of work to stretch a spring 0.5 m from its equilibrium position. How much work is needed to stretch it an additional 0.75 m?

Let that sink in for a moment. They aren’t giving me the constant $$k$$ that I need to complete this problem. Or are they? They are giving me $$\text{W}$$ and $$x$$, so perhaps this can work out?

$$
\begin{aligned}
\int_0^{\frac{1}{2}}kx\,dx&=100\\
\left.\begin{matrix}\frac{k}{2}x^2\end{matrix}\right|_0^\frac{1}{2}&=100\\
\left(\frac{k}{2}\cdot\frac{1}{4}\right)-\left(\frac{k}{2}\cdot\frac{0}{2}\right)&=100\\
\frac{k}{8}&=100\\
k&=800
\end{aligned}
$$

Therefore, we can now perform the last part of the problem:

$$
\begin{aligned}
\int_\frac{1}{2}^\frac{5}{4}800x\,dx&=\left.\begin{matrix}400x^2\end{matrix}\right|_\frac{1}{2}^\frac{5}{4}\\
&=\left[400\cdot\left(\frac{5}{4}\right)^2\right]-\left[400\cdot\left(\frac{1}{2}\right)^2\right]\\
&=525\text{J}\end{aligned}
$$

By using the definite integral we can expand what we do know into some algebra to fill in what we didn’t know, and thereby can find out more.

Perhaps someday we’ll find out what special materials these math textbooks have which allows them to create infinitely stretchable springs, because I’m still mad about the slinky that I broke when I was ten. No child should have to go through that kind of disappointment. They’re holding out on us, I tell you. They’re holding out.

*This is a solution for §6.6 #21 from* Calculus: Early Transcendentals.
