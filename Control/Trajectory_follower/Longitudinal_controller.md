Longitudinal Controller
=============

# Overview

For following target trajectory, control stack needs to output lateral control commands (steering angle, steering angle velocty), and logitudinal control commands (acceleration, velocity). Logitudinal controller module is responsible for calculation of logitudinal control commands.

## Role

Lateral controller module calculates suitable steering angle and steering angle velocity for following target trajectory. This module balances distance/yaw error from target trajectory, and smoothness of movement.

### Input

- Target trajectory
	- Target trajectory includes target position, target orientation, target twist, target acceleration
- Current velocity
- Current steering

### Output

- Velocity command
- Acceleration command
