Vehicle Cmd Gate
=============

# Overview
Vehicle Cmd Gate module is responsible for Systematic post-processing

## Role

Roles of Vehicle Cmd Gate module are as follows.

- Reshape the vehicle control command
- Select the command values (Trajectory follow command, Remote manual command)
- Observe the maximum speed limit, maximum lateral/longitudinal jerk
- Stop urgently when emergency command is received

### Input

- Control commands from Trajectory Follower module
- Remote Control commands
- Engage Commands

### Output

- Control signal for vehicles
