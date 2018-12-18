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

<p align="center">
$$P_x(x,y) = a_0+a_1x+a_2y+a_3xy+a_4x^2+a_5y^2$$  
$$P_y(x,y) = b_0+b_1x+b_2y+b_3xy+b_4x^2+b_5y^2$$ 
</p>

<iframe src="https://www.openprocessing.org/sketch/646277/embed/" width="650" height="670"></iframe>
