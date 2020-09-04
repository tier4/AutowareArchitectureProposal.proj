# Control

# Overview

Control stack generates control signals to drive a vehicle following trajectories considering vehicle dynamics.
This layer ensures that the vehicle follows the trajectory planned by planning.
The output of Control stack includes velocity, acceleration, and steering.

## Role

There are two main roles of Control Stack:

- **Generation of control command for following target trajectory**


## Use Case

Control stack supports the following use cases.

1. Driving without excessive speed
2. Driving at slope
3. Smooth stop by normal obstacles / Sudden stop by obstacle's running-out
4. Forward/Reverse parking

## Requirement

To achieve the above use case, Control stack requires the following conditions.

- The input trajectory includes reference speed at each point (Use case 1).
- The input pose includes gradient information (=vehicle orientation) (Use case 2).
- The output vehicle command includes acceleration but also velocity (Use case 2, 3).

## Assumption

- For accurate control, the input trajectory is expected to have motion information with a resolution of about 0.1s. However, in any case, control should operate it properly with resampling.


## Input

The input to Control stack:

| Input         | Topic (Data Type)                   | Explanation                             |
| ------------- | ----------------------------------- | --------------------------------------- |
| Trajectory    | autoware_planning_msgs::Trajectory  | Target trajectory to follow             |
| MotionState   | autoware_control_msgs::MotionState  | Current vehicle motion state including pose, velocity, stering, etc.      |

As the above requirements, the data type of target trajectory, `autoware_planning_msgs::Trajectory`, includes the speed at each point.


**autoware_planning_msgs/Trajectory**
```
std_msgs/Header  header
autoware_planning_msgs/TrajectoryPoint  points[]
uint32 CAPACITY=100
```

**autoware_planning_msgs/TrajectoryPoint**
```
builtin_interfaces/Duration  time_from_start
geometry_msgs/Pose pose
std_msgs/Float32 longitudinal_velocity
std_msgs/Float32 longitudinal_acceleration
std_msgs/Float32 yaw_rate
std_msgs/Float32 lateral_velocity  # need more discussion
std_msgs/Float32 steering_angle    # need more discussion
```

**autoware_control_msgs/MotionState**
```
std_msgs/Header header
geometry_msgs/Pose pose
std_msgs/Float32 longitudinal_velocity
std_msgs/Float32 longitudinal_acceleration
std_msgs/Float32 yaw_rate
std_msgs/Float32 lateral_velocity
std_msgs/Float32 steering_angle
```

### Output

The table below summarizes the output from Control stack:

| Output          | Topic(Data Type)                       | Explanation |
| --------------- | -------------------------------------- | ----------- |
| Control Command | `autoware_control_msgs/ControlCommand` | Table Below |


**autoware_control_msgs/ControlCommand**
```
builtin_interfaces/Time stamp
std_msgs/Float32 velocity
std_msgs/Float32 acceleration
std_msgs/Float32 steering_angle
std_msgs/Float32 steering_angle_rate
```


# Design

![ControlOverview](/design/img/ControlOverview.png)

## Trajectory follower

### Role

Generate control command for following given trajectory.

### Input

- Target trajectory
  - Target trajectory includes target position, orentation, velocity, yawrate, and acceleration.
- Current motion state
  - motion state includes current position, orientation, velocity, yawrate, acceleration, and steering angle.

### Output

- Velocity command
- Acceleration command
- Steering angle command
- Steering angle rate command

# References

TBU


## Difference from the AutowareArchitectureProposal / AutowareAuto

### From AutowareArchitectureProposal
 - The `vehicle_cmd_gate` node is moved to the Vehicle stack.
 - The unused fields is removed (e.g. angular velocity on the x axes).
 - Use Float (not Double) since the control stack works only in the local coordinates.
 - gear and emergency command is separated from the `/vehicle_command` since the velocity and other kinetic information and gears have different frequencies that are required. The emergency command is managed by a separate safety stack.
 - time_from_start is added in the reference trajectory to support time-based requirement from the planning stack


### From AutowareAuto

 - 2.5D information is added (e.g. z-position) for sloping road or multi level carpark usecases
 - Three control commands (HighLevel / LowLevel / Normal) are conbined into one topic. If the vehicle requires the accel / brake level command, they are generated from the control command in the vehicle stack.


## Brief summary of the discussed point

- having jerk in the control command
  - it is removed since the performance improvement is not much enough to outweigh the disadvantages of forcing all controllers to calculate the jerk

- having steerng and lateral_velocity in the TrajectoryPoint
  - they are contained in autoware.auto, but intentionally removed in the original proposal
  - pros: precisely calculated trajectory motion information improves the performance of control (e.g. the MPC uses those instructions as reference)
  - cons: control and planning are tightly coupled (e.g. control module needs to know the information of the motion model used in the planning since steerng and lateral_velocity depends on the motion model )

 - having the covariance in the estimated state