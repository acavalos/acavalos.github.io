---
published: true
---
## Fun Simulation

One of my favorite objects to visualize are strange attractors. Those interested in maths or physics have probably heard of the usual suspect, The Lorenz Attractor.  

<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/1/13/A_Trajectory_Through_Phase_Space_in_a_Lorenz_Attractor.gif">
</p>  

The Lorenz Attractor can be visualized by numerically solving the system of partial differential equations:

<p align="center">
$$  
\begin{align}
\frac{dx,dt} & = \sigma(y-x) \\
\frac{dy,dt} & = x(\rho-z)-y \\  
\frac{dz,dt} & = xy - \beta z  
\end{align}
$$  
</p>

$$P_x(x,y) = a_0+a_1x+a_2y+a_3xy+a_4x^2+a_5y^2$$  
$$P_y(x,y) = b_0+b_1x+b_2y+b_3xy+b_4x^2+b_5y^2$$  
<iframe src="https://www.openprocessing.org/sketch/646277/embed/" width="650" height="670"></iframe>
