---
title:      Simplify the Expression
date:       2013-10-28
summary:    A really nifty algebraic simplification.
---

$$
Ce^{\ln^2 x}=C\left(e^{\ln x}\right)^{\ln x}=Cx^{\ln x}
$$

This sequence interests me chiefly because at first glance it looks
wrong. $$ e^{\ln^2 x} $$ should expand to $$ \left(e^{\ln
x}\right)^{2} $$, should it not? Only, it doesn't because of the algebraic properties of exponents.

$$
\begin{array}{rrl}
x^y+x^y&&=2x^y\\
x^y\cdot x^y&=\left(x^y\right)^2&=x^{2y}\\
\left(x^y\right)^y&&=x^{y^2}\\
&\left(x\land y\right)\in \mathbb{R}
\end{array}
$$

Given such context, it makes more sense and becomes more obvious why the original simplifies the way it does.

*I restrict $$x$$ and $$y$$ to $$\mathbb{R}$$ because I haven't yet investigated whether the properties hold for the imaginary numbers.*
