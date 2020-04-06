Control
=============

# Overview 

Control stack generates control signals to drive a vehicle following trajectorys considering vehicle dynamics.

## Role

There are two main roles of Control Stack:

- **Generation of control command for following target trajectory**
- **Post-processing of vehicle control command**

## Use Case

Control stack supports the following use cases.

- Driving without collision with obstacles or overspeed
- Driving at slope
- Smooth stop by normal obstacles / Sudden stop by obstacle's running-out
- Foward/Reverse parking

## Requirement

In order to achieve above use case, control stack require the following conditions.

- The input trajectory includes speed limit at each point.
- The input trajectory includes gradient information.
- The output vehicle command includes accleration but also velocity.
- The output vehicle command includes the command to shift drive/reverse gear.


## Input

The input to Control stack:

| Input          | Data Type                            | Explanation                             |
| -------------- | ------------------------------------ | --------------------------------------- |
| Trajectory     | `autoware_planning_msgs::Trajectory` | Target trajectory to follow             |
| Twist Command  | `geometry_msgs::TwistStamped`        | Current twist of the vehicle            |
| Steer Command  | `autoware_vehicle_msgs::Steering`    | Current steer of the vehicle            |
| Engage Command | `std_msgs::Bool`                     | Whether to send commands to the vehicle |
| Remote Command | -                                    | Control command from remote             |

### Output

The table below summarizes the output from Control stack:

| Output              | Data Type                            | Explanation                |
| ------------------- | ------------------------------------ | -------------------------- |
| Vehicle Command     | autoware_vehicle_msgs/VehicleCommand | Table Below                |
| Turn signal Command | autoware_vehicle_msgs/TurnSignal     | State of turn signal light |

The main outputs included in Vehicle Command are as follows.

| Output                  | Data Type        |
| ----------------------- | ---------------- |
| Velocity                | std_msgs/Float64 |
| Acceleration            | std_msgs/Float64 |
| Steering angle          | std_msgs/Float64 |
| Steering angle velocity | std_msgs/Float64 |
| Gear shifting command   | std_msgs/Int32   |
| Emergency command       | std_msgs/Int32   |

# Design

![Control_component](/img/Control_overview.svg)

## Trajectory follower

### Role

Generate control command for following given trajectory smoothly.

### Input

- Target trajectory
	- Target trajectory includes target position, target orientation, target twist, target acceleration
- Current velocity
- Current steering

### Output

- Steering angle command
- Steering angular velocity command
- Velocity command 
- Acceleration command

## Vehicle command gate

### Role

Systematic post-processing of vehicle control command, independent of trajectory following process

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

# References

TBU