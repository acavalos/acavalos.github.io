---
published: true
---
## Fun Simulation

One dying subject, but fascinating to myself, is the study of chaos. Those interested in maths or physics have probably heard of the usual suspect, The Lorenz Attractor. The Lorenz Attractor can be visualized by numerically solving the system of partial differential equations:
<p align="center">
$$
\begin{aligned}
\frac{dx}{dt} & = \sigma(y-x) \\
\frac{dy}{dt} & = x(\rho-z)-y \\  
\frac{dz}{dt} & = xy - \beta z  
\end{aligned}
$$    
</p>

A famous model for weather systems, this object might be the real origin of "The Butterfly Effect," for obvious reasons:

<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/1/13/A_Trajectory_Through_Phase_Space_in_a_Lorenz_Attractor.gif">
</p>  

But this example is overdone, not simple enough for the layman, and overall boring.  

## Strange Attractors Birthed From Quadratic Polynomials
Goodbye differentials, hello recursion. While my mathematical gut tells me the maths to follow is heavily tied to Partial Differential Equations(and maybe even Complex Analysis!), the following should be accessible to those who have completed basic calculus. 

## The Process
For our simulation, we will start with N amount of 'dust particles'. For every frame, will will feed each particles x and y coordinates into the following system of polynomials:

<p align="center">
$$
\begin{aligned}
P_x(x,y) & = a_0+a_1x+a_2y+a_3xy+a_4x^2+a_5y^2 \\ 
P_y(x,y) & = b_0+b_1x+b_2y+b_3xy+b_4x^2+b_5y^2
\end{aligned}
$$ 
</p>  

Since we need the particles to both NOT escape to infinity and NOT converge onto a fixed point or path(both of these things are inevitable), we have two necessary constraints; the polynomial coefficients and dust particles will be spawned within the unit circle, and each particle will only update at most 20 times before being regenerated into a new random point. By doing this, we improve our chances at a successful, interesting image, and spend less resources checking for divergence. 

## The Simulation 
<p align="center">
<iframe src="https://www.openprocessing.org/sketch/646277/embed/" width="650" height="670"></iframe>
</p>

### Controls
$$
/begin{aligned}
'wasd' & : Translate image \\
'r' & : Zoom In \\
'f' & : Zoom Out \\
'm' & : Change Mode \\
'n' & : Generate New Attractor \\
$$

