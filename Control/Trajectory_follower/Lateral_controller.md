Lateral Controller
=============

# Overview

For following target trajectory, control stack needs to output lateral control commands (steering angle, steering angle velocty), and logitudinal control commands (acceleration, velocity). Lateral controller module is responsible for calculation of lateral control commands.

## Role

Lateral controller module calculates suitable velocity and acceleration for following target trajectory.

### Input

- Target trajectory
	- Target trajectory includes target position, target orientation, target twist, target acceleration
- Current velocity
- Current steering

### Output

- Steering angle command
- Steering angular velocity command
