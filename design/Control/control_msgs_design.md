

# Changes From Autoware.Auto

**Trajectory**
 - 3D information for the position (z) and orientation (roll, pitch) is added for slope road or multi-level carpark usecases.
 - Position and orientation are combined into `geometry/Pose` message.
 - The rear_wheel_angle is removed to focus on the front-wheel drive vehicles. We will consider to bring this back when it is needed for the targetting usecases in the future.


**VehicleKinematicState**
 - The source for this topic has been changed to Localization from the Vehicle Interface because this type of information contains more information than the vehicle alone can provide.
 - `geometry_msgs/Transform delta` is removed from it's field.

**VehicleMotionCommand**
 - This replace three existing message types: `HighLevelControlCommand`, `LowLevelControlCommand`, and `VehicleMotionCommand`.
 - For the simplicity of controller development, the output from the control module is fixed with one topic.
 - `HighLevelControlCommand` command is removed since it can be converted from the `ControlCommand`.
 - `LowLevelControlCommand` will remain, but it is used only in the conversion from ControlCommand, not the output of the control module. This allows control modules to be designed without taking into account low level vehicle-specific information such as mapping between acceletation and throttle.


**VehicleMotionReport**
 - This replace the `VehicleOdometry`, output from the Vehicle Interface.
 - This message is interpreted as sensor information from vehicle. The odometry will be the output from the Localization module (e.g. dead_reckoning_node).


**VehicleSystemCommand**
 - The same as the `VehicleStateCommand`.

**VehicleSystemReport**
 - The same as the `VehicleStateReport`.









# Interface Messages





## Trajectory


```
std_msgs/Header header
TrajectoryPoint[<=100] points
```

**Source**: Planning

**Recipient(s)**: Control


**Rationale**: A bounded number of points is provided since a new trajectory should be provided at a regular rate. Bounded data structures also imply more deterministic communication times due to having a bounded size.

**Note**: For accurate tracking control, the trajectory is expected to have motion information with a resolution of about 0.1s. However, in any case, control should operate it properly with resampling.






## Vehicle Kinematic State
**Source**: Localization

**Recipient(s)**: Planning, Control
```
std_msgs/Header header
TrajectoryPoint state
```

The `TrajectoryPoint::time_from_start` field should also be filled with the time difference between the current state and the previous state message.

The position fields of the `TrajectoryPoint` member should contain the position of the ego vehicle with respect to a fixed frame, if available. If the frame is a dynamic frame (e.g. `base_link`), then this position field should be taken as unavailable or invalid. The further kinematics of this member should always be available, and populated according to the appropriate coordinate frame, making the additional assumption that the coordinate frame is static.

The delta member is the transform of the message should represent the positional update of the ego vehicle's coordinate frame relative to it's last position and orientation.

**Source**: Vehicle State Estimator

**Recipient(s)**: Planning stack (Route planner, Behavior Planner, Motion Planner, Controller), Tracker

**Default Values**: The trajectory point should be appropriately default initialized

**Default Values**: The delta transform field should have zero translation and the unit quaternion by default.

**Extensions**: State and transform uncertainty may be added as variances or covariance matrices. This may be necessary for probabilistic algorithms (e.g. robust MPC)

**Rationale**: An underlying trajectory point is used because kinematic information may be needed by controllers. Further, representing the vehicle state in a manner that mirrors the trajectory fits with the semantic purpose of a controller: matching the current state to a state sequence

**Rationale**: A transform relative to the previous position and orientation of the ego vehicle is provided because while absolute position may not always be available with accuracy, this relative transform should be available with some degree of accuracy (e.g. via IMU information, odometry information, etc.). The availability of this information allows for planning and tracking within a local coordinate frame. For example, in a level 3 highway driving use case, a trajectory may be rooted at the ego vehicle's position at some time stamp. The accumulation of these relative transforms would allow for a controller to properly follow the trajectory.

**Rationale**: The kinematics are populated with a fixed frame assumption to simplify the updates and usage of this field.

For more details, see [Controller design](@ref controller-design)
















## Vehicle Motion Command



```
builtin_interfaces/Time stamp
Float32 velocity       # desired velocity for the baselink [m/s]
Float32 acceleration   # desired acceleration for the baselink [m/ss]
Float32 steering       # desired steering angle [rad]
Float32 steering_rate  # desired steering anglular velocity [rad/s]
```

**Source**: Control

**Recipient(s)**: Vehicle Interface


This message type is provided as abstract information to describe the motion of the vehicle, which is a convenient representation for controller developers.

The vehicle will be driven with all or specific information contained in this message. For example, it is assumed that the vehicle with the target steering angle and acceleration interface will move with reference to the steering and acceleration field only.

If the vehicle requires another level of information such as a brake or throttle, it will be converted to the `RawVehicleMotionCommand` in a later stage.



These steering are counter-clockwise positive, where 0 corresponds to a neutral, or
forward-facing orientation.



**Default Values**: The default value for all fields is 0

**Rationale**: A time stamp field is provided because a control command should be generated in response to the input of a vehicle kinematic state. Retaining the time of the triggering data should aid with diagnostics and traceability.

**Rationale**: A single acceleration field is provided because controllers typically plan a longitudinal acceleration and turning angle for the rigid body. Braking is baked into this single command for simplicity of controller development, and because it is generally not expected for both the brake to be depressed and the accelerator at the same time.

**Rationale**: Wheel steering angles are provided since it allows the controller to only require a simplified view of the vehicle platform, such as knowing the wheelbase length. Depending on the implementation of a drive-by-wire interface, producing a given wheel angle may require knowledge of the mapping between steering wheel angle to wheel angle.

**Rationale**: Steering rate field is added to leave a choice of low-level control commands.

**Rational**: A frame is not provided since it is implied that it is fixed to the `base_link` frame.



























## Vehicle Motion Report

```
builtin_interfaces/Time stamp
Float32 velocity
Float32 steering
```

This message reports the kinematic state of the vehicle as the vehicle itself reports. The intended
use case for this message could be in motion planning for initial conditions, or dead reckoning.

**Source**: Vehicle Interface

**Recipient(s)**: Localization

**Default Values**: The default value for this message should be 0 in all fields.

**Rationale**: This message is separate from the vehicle state report since they are typically for
distinct use cases (e.g. behavior planning vs dead reckoning)

**Rationale**: A vehicle is expected to have encoders which provide velocity, and steering angle.
Acceleration and other fields may not be available on all vehicle platforms.

**Rationale**: A stamp is expected here because this is timely information. In this sense, the
vehicle interface is acting as a sensor driver.

**Rationale**: A frame id is not provided because these are assumed to be fixed to the vehicle
frame, and heading information is not available.









## Vehicle System Command

**Source**: Planning

**Recipient(s)**: Vehicle Interface

```
builtin_interfaces/Time stamp
uint8 blinker
uint8 headlight
uint8 wiper
uint8 gear
uint8 mode
bool hand_brake
bool horn
bool autonomous

### Definitions
# Blinker
uint8 BLINKER_OFF = 0
uint8 BLINKER_LEFT = 1
uint8 BLINKER_RIGHT = 2
uint8 BLINKER_HAZARD = 3
# Headlight
uint8 HEADLIGHT_OFF = 0
uint8 HEADLIGHT_ON = 1
uint8 HEADLIGHT_HIGH = 2
# Wiper
uint8 WIPER_OFF = 0
uint8 WIPER_LOW = 1
uint8 WIPER_HIGH = 2
uint8 WIPER_CLEAN = 3
# Gear
uint8 GEAR_DRIVE = 0
uint8 GEAR_REVERSE = 0
uint8 GEAR_PARK = 2
uint8 GEAR_LOW = 3
uint8 GEAR_NEUTRAL = 4
```

This message is intended to control the remainder of the vehicle state, e.g. those not required for minimal collision-free driving.


**Default Values**: The default value for all fields should be zero.

**Rationale**: Hazard lights superseded a left/right signal, and as such are an exclusive state

**Rationale**: Cleaning might be necessary to ensure adequate operation of sensors mounted behind the wind shield

**Rationale**: A horn might be required to signal to other drivers

**Rationale**: Autonomous is a flag because this is a command message: true requests a transition to autonomous, false requests a disengagement to manual.

**Rationale**: While additional states are possible for other fields (e.g. headlights, wipers, gears, etc.), this message only prescribes the minimal set of states that most or all vehicles can satisfy.

**Rationale**: Since commands here represent a state transition, a command of NONE denotion "no state transition" is also valid


**Note**: If additional information is neded in your project, such as door open/close information, you need to add them as a separate topic, rather than changing this message. This is necessary in order to share the topic between projects. If there will be widely used topica, it will be added in the major release.








## Vehicle System Report

**Source**: Vehicle Interface

**Recipient(s)**: Planning

```
builtin_interfaces/Time stamp
uint8 fuel      # 0 to 100
uint8 blinker
uint8 headlight
uint8 wiper
uint8 gear
uint8 mode
bool hand_brake
bool horn

### Definitions
# Blinker
uint8 BLINKER_OFF = 1
uint8 BLINKER_LEFT = 2
uint8 BLINKER_RIGHT = 3
uint8 BLINKER_HAZARD = 4
# Headlight
uint8 HEADLIGHT_OFF = 1
uint8 HEADLIGHT_ON = 2
uint8 HEADLIGHT_HIGH = 3
# Wiper
uint8 WIPER_OFF = 1
uint8 WIPER_LOW = 2
uint8 WIPER_HIGH = 3
uint8 WIPER_CLEAN = 4
# Gear
uint8 GEAR_DRIVE = 1
uint8 GEAR_REVERSE = 2
uint8 GEAR_PARK = 3
uint8 GEAR_LOW = 4
uint8 GEAR_NEUTRAL = 5
# Mode
uint8 MODE_AUTONOMOUS = 1
uint8 MODE_MANUAL = 2
uint8 MODE_DISENGAGED = 3
uint8 MODE_NOT_READY = 4
```


**Default Value**: N/A. All fields should be populatable by the vehicle interface.

**Rationale**: A discrete fuel range is provided as finer granularity is likely unnecessary.

**Rationale**: A simple state machine is provided to ensure that disambiguate between intentionally
manual, and two modes of unintentionally being in manual mode: due to preconditions not being met,
or due to some failure of the autonomous driving stack.

**Rationale**: Constants are kept the same as VehicleSystemCommand to prevent subtle bugs from being
introduced. The constant 0 is reserved for NO_COMMAND in VehicleSystemCommand.








## Control Diagnostic

**Source**: Controller

**Recipient(s)**: -

```
DiagnosticHeader header
bool new_trajectory
string trajectory_source
string pose_source
float32 lateral_error_m
float32 longitudinal_error_m
float32 velocity_error_mps
float32 acceleration_error_mps2
float32 yaw_error_rad
float32 yaw_rate_error_rps
```

**Rationale**: Diagnostic information is helpful to detect if a fault occurred, or some incorrect
behavior leading up to a fault. It can also be used for infotainment applications.

For more details, see [Controller design](@ref controller-design)















# Helper Types


## TrajectoryPoint


```
builtin_interfaces/Duration  time_from_start
geometry_msgs/Pose pose
Float32 longitudinal_velocity
Float32 longitudinal_acceleration
Float32 yaw_rate
Float32 lateral_velocity  # need more discussion
Float32 steering          # need more discussion
```


**Default Values**: All trajectory point and trajectory fields should default to 0

**Default Values**: All quaternion numbers should default to (w, x, y, z) = (1, 0, 0, 0), which corresponds to a zero orientation.

**Rationale**: Trajectory points mirror, but are not the same as a standard JointTrajectory message. This is because the standard message allows room for ambiguities whereas this message does not.

**Rationale**: Higher derivative information (e.g. acceleration, heading rate) is available to provide a more expressive language for controllers and trajectory planners. If the information is not needed, a value of zero is provided, which is semantically consistent for controllers and motion planners









## RawVehicleMotionCommand

This message type is defined as follows:

```
builtin_interfaces/Time stamp
Float32 throttle       # desired throttle [-]
Float32 brake          # desired brake [-]
Float32 steering       # desired steering angle [rad]
Float32 steering_rate  # desired steering anglular velocity [rad/s]
```

This type is intended to be used when direct control of the vehicle hardware is required. As such, no assumptions about units are made. It is the responsibility of the system integrator to ensure that the values used are appropriate for the vehicle platform.


**Default Values**: The default value for all fields is 0

**Rationale**: A time stamp field is provided because a control command should be generated in response to the input of a vehicle kinematic state. Retaining the time of the triggering data should aid with diagnostics and traceability.

**Rationale**: The rear wheel angle is also provided to enable support for rear drive vehicles, such as forklifts.

**Rationale**: A frame is not provided since it is implied that it is fixed to the vehicle frame.

**Rationale**: Throttle and brake are separated as they are fundamentally controlled by two different actuators

**Rationale**: This is intended to be compatible with using the triggers of a gamepad as a first pass for vehicle platform validation.

**Rationale**: Integer values are used to be more compatible with discrete, or byte-level representation that is more common with CAN interfaces.

**Rationale**: Units are not provided since byte-level representations are generally platform-specific.

For more details see [vehicle interface design]().












# References

- AutowareAuto#62

## Related Message Types

### ROS

- [JointTrajectory.msg](https://github.com/ros2/common_interfaces/blob/master/trajectory_msgs/msg/JointTrajectoryPoint.msg)
- [PointStamped](http://docs.ros.org/lunar/api/geometry_msgs/html/msg/PointStamped.html)
- [PoseStamped](http://docs.ros.org/lunar/api/geometry_msgs/html/msg/PoseStamped.html)
- [TransformStamped](http://docs.ros.org/melodic/api/geometry_msgs/html/msg/TransformStamped.html)
- [NavSatFix](http://docs.ros.org/melodic/api/sensor_msgs/html/msg/NavSatFix.html)

### Autoware.AI

- [AccelCmd](https://github.com/CPFL/Autoware/blob/master/ros/src/msgs/autoware_msgs/msg/AccelCmd.msg)
- [BrakeCmd](https://github.com/CPFL/Autoware/blob/master/ros/src/msgs/autoware_msgs/msg/BrakeCmd.msg)
- [ControlCmd](https://github.com/CPFL/Autoware/blob/master/ros/src/msgs/autoware_msgs/msg/ControlCommand.msg)
- [IndicatorCmd](https://github.com/CPFL/Autoware/blob/master/ros/src/msgs/autoware_msgs/msg/IndicatorCmd.msg)
- [LampCmd](https://github.com/CPFL/Autoware/blob/master/ros/src/msgs/autoware_msgs/msg/LampCmd.msg)
- [RemoteCmd](https://github.com/CPFL/Autoware/blob/master/ros/src/msgs/autoware_msgs/msg/RemoteCmd.msg)
- [SteerCmd](https://github.com/CPFL/Autoware/blob/master/ros/src/msgs/autoware_msgs/msg/SteerCmd.msg)
- [VehicleCmd](https://github.com/CPFL/Autoware/blob/master/ros/src/msgs/autoware_msgs/msg/VehicleCmd.msg)
- [VehicleStatus](https://github.com/CPFL/Autoware/blob/master/ros/src/msgs/autoware_msgs/msg/VehicleStatus.msg)
- [Waypoint](https://github.com/CPFL/Autoware/blob/master/ros/src/msgs/autoware_msgs/msg/Waypoint.msg)

### Apollo

Controller/Interface Messages
- [VehicleSignal](https://github.com/ApolloAuto/apollo/blob/fb12723bd6dcba88ecccb6123ea850da1e050171/modules/common/proto/vehicle_signal.proto)
- [Lexus](https://github.com/ApolloAuto/apollo/blob/51651b9105e55c14e65cc2bd349b479e55fffa36/modules/canbus/proto/lexus.proto)
- [DriveState](https://github.com/ApolloAuto/apollo/blob/51651b9105e55c14e65cc2bd349b479e55fffa36/modules/common/proto/drive_state.proto)
- [VehicleState](https://github.com/ApolloAuto/apollo/blob/51651b9105e55c14e65cc2bd349b479e55fffa36/modules/common/vehicle_state/proto/vehicle_state.proto)
- [ControlCmd](https://github.com/ApolloAuto/apollo/blob/3d6f86e21a3c3ac43cf08423d4c3f92bc63ecac9/modules/control/proto/control_cmd.proto)

Configuration Messages
- [LonControllerConf](https://github.com/ApolloAuto/apollo/blob/3d6f86e21a3c3ac43cf08423d4c3f92bc63ecac9/modules/control/proto/lon_controller_conf.proto)
- [LatControllerConf](https://github.com/ApolloAuto/apollo/blob/e9156ced04a8f0e372c781d803fd43428ab6c497/modules/control/proto/lat_controller_conf.proto)
- [ControlConf](https://github.com/ApolloAuto/apollo/blob/51651b9105e55c14e65cc2bd349b479e55fffa36/modules/control/proto/control_conf.proto)
- [MPCControllerConf](https://github.com/ApolloAuto/apollo/blob/51651b9105e55c14e65cc2bd349b479e55fffa36/modules/control/proto/mpc_controller_conf.proto)

Algorithm Status Messages
- [PlanningStatus](https://github.com/ApolloAuto/apollo/blob/51651b9105e55c14e65cc2bd349b479e55fffa36/modules/planning/proto/planning_status.proto)
- [LocalizationStatus](https://github.com/ApolloAuto/apollo/blob/51651b9105e55c14e65cc2bd349b479e55fffa36/modules/localization/proto/localization_status.proto)
- [PlanningStats](https://github.com/ApolloAuto/apollo/blob/51651b9105e55c14e65cc2bd349b479e55fffa36/modules/planning/proto/planning_stats.proto)