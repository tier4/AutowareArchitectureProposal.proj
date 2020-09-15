# Control



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


## Input

The input to Control stack:

| Input         | Topic (Data Type)                   | Explanation                             |
| ------------- | ----------------------------------- | --------------------------------------- |
| Trajectory    | `autoware_planning_msgs/Trajectory`  | Target trajectory to follow             |
| MotionState   | `autoware_control_msgs/MotionState`  | Current vehicle motion state including pose, velocity, stering, etc.      |

As the above requirements, the data type of target trajectory, `autoware_planning_msgs/Trajectory`, includes the speed at each point.

## Output

The table below summarizes the output from Control stack:

| Output          | Topic(Data Type)                       | Explanation |
| --------------- | -------------------------------------- | ----------- |
| Vehicle Motion Command | `autoware_control_msgs/VehicleMotionCommand` | Link? |


# Implementation Example

Here is an example of two different control module implementations. Note that both of the input/output of the `trajectory_follower` is same as those specified in the interface.

![ControlExampleImpl1](/design/img/ControlExampleImpl1.png)

This is an example implementation of the control module in Autoware.Auto. The `mpc_controller` calculates the `vehicleMotionCommad` based on the target `Trajectory` and current `MotionState`. This node calculates velocity, acceleration, steer angle and steer angle speed simultaneously.


![ControlExampleImpl2](/design/img/ControlExampleImpl2.png)


This is an example implementation of the control module in the Autoware.IV. The `lateral_controller` calculates the steer angle and steer angular velocity based on the target `Trajectory` and current `MotionStatus`. This output message is implementation dependent and is not specified as the interface of the Autoware. Here, for example, the `VehicleMotionCommad` is used as an output of the `lateral_controler`, where only the steering and the steering rate fields are set.
Similarly, `longitudinal_controller` calculates the target velocity and acceleration from the target `Trajectory` and current `MotionStatus`. 
The output from these two controllers is integrated by `latlon_coupler` and is published to the vehicle as one topic. 
