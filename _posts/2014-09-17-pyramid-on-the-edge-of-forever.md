---
title:      Pyramid on the Edge of Forever
date:       2014-09-15 12:44:29
summary:    The sales associate at Kelly Moore looked at me as if I had grown a third arm right there in front of him.
---

I was walking through the forest one day, enjoying the soft warmth filtering through the pines and the funny secretion noises of the banana slugs copulating on the trail in front of me. Some of the trees are charred and blackened from fire, but their neighbors are not. Why?

<!--more-->

As I ponder upon this conundrum, is it lightning strikes? Arsonists? A great pyramid arises in the forest. As I approach the corner of the base, I immediately notice that the pyramid's base is a square. Engraved near that corner are two measurements: four meters wide, three meters tall.

A voice not unlike that of the Guardian of Forever commands: "Since before your sun burned hot in space and before your race was born, I have awaited a new coat of paint on my northern face."

I don't want to paint the pyramid, but I must do as I am bidden.

I am not now, nor have I ever been, a person of much financial means, so I want to obtain the least amount of paint possible to accomplish the task. This begs the question, what is the area of the northern face?

The points of the pyramid can be expressed as position vectors. Because of symmetry in pyramids, we only need to know the area of any face, not identify the northern face itself. The first position is easy: $$\mathbb{0}$$. The next position is also trivial: $$\mathbf{V}=<4,0,0>$$.

The last position, the top point of the pyramid, requires further thought. The top point will be in the middle of the pyramid as you look down from above, and it will be the height above that point: $$\mathbf{U}=<2,2,3>$$.

We can use a formula for the area of a triangle formed by two vectors, $$A=\frac{1}{2}\begin{vmatrix}\mathbf{U}\end{vmatrix}\cdot\begin{vmatrix}\mathbf{V}\end{vmatrix}\sin\theta$$.

By recognizing the identity of a cross-product, we arrive at

$$A=\frac{1}{2}\begin{vmatrix}\mathbf{U}\times\mathbf{V}\end{vmatrix}.$$

Instantiating the equation with our found values, I performed the calculations to find the area of the north face of the pyramid.

$$
\begin{array}{rl}
\mathbf{U}\times\mathbf{V}&=4\hat{i}\times\left(2\hat{i}+2\hat{j}+3\hat{k}\right)\\
&=8\hat{i}\times\hat{i}+8\hat{i}\times\hat{j}-12\hat{i}\times\hat{k}\\
&=-12\hat{j}+8\hat{k}\\
&=4\left(-3\hat{j}+2\hat{k}\right)\\
\left|\mathbf{U}\times\mathbf{V}\right|&=4\sqrt{(-3)^2+2^2}\\
\frac{1}{2}\left|\mathbf{U}\times\mathbf{V}\right|&=\frac{1}{2}\cdot4\sqrt{13}\\
&=2\sqrt{13}\\

\end{array}
$$

Armed with this knowledge, that the area of the northern face was $$2\sqrt{13}\,m^2$$, I set off to a nearby Kelly Moore paint store in the forest. The young man at the desk seemed bewildered to see someone.

"I need $$2\sqrt{13}\,m^2$$ worth of paint." I demanded.

He looked at me as if I had grown a third arm right there in front of him. I double-checked, and could find no tertiary manipulative appendage. I found this lack of development disappointing. Imagine the things I could do with three arms! Type and wipe the sweat off my brow at the same time! Type and use the mouse at the same time! Push-ups would be about $$\frac{1}{3}$$ easier than they are now. Or would they, without a quaternary force to counterbalance the new pectoralis muscle?

This requires further thought.

After a few moments the young man produced a small can of bright-orange paint. For $19.99 and a marginal VAT I returned to the pyramid, which had disappeared. I was certain that I retraced my steps properly, but the structure, the mysterious edifice, was simply absent.

I heard its voice again: "Time has resumed its shape. All is as it was before."

And that's how I wandered out of Big Basin National Forest with a can of paint.
