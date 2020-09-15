# Vehicle

# Overview

Vehicle stack is an interface between Autoware and vehicle. This layer converts signals from Autoware to vehicle-specific, and vice versa.
This module needs to be designed according to the vehicle to be used. How to implement a new interface is described [below.](#how-to-design-a-new-vehicle-interface)


# Design

For vehicles of the type controlled by the target velocity or acceleration (type A)

![Vehicle_design_typeA](/design/img/VehicleInterfaceDesign1_reviewed.png)


For vehicles of the type controlled by the target throttle and brake pedals (type B)

![Vehicle_design_typeB](/design/img/VehicleInterfaceDesign2_reviewed.png)



## Input

The input to Vehicle stack:

| Input                      | Topic(Data Type)                                                   | Explanation |
| ----------------------     | ------------------------------------------------------------------ | ----------- |
| Vehicle Motion Command     | `autoware_auto_msgs/VehicleMotionCommand`                          | Table Below |
| Vehicle System Command     | `autoware_auto_msgs/VehicleSystemCommand`                          | Table Below |
| Raw Vehicle Motion Command | `autoware_auto_msgs/RawVehicleSystemCommand`                       | Table Below |

The detailed contents in Vehicle Motion / System Command are as follows.



### Output

There are two types of outputs from Vehicle stack: vehicle report to Autoware and a control command to the vehicle.

The table below summarizes the output from Vehicle stack:

| Output (to Autoware)   | Topic(Data Type)                               | Explanation                                 |
| ---------------        | ---------------------------------------------- | ------------------------                    |
| Vehicle Motion Report  | `autoware_auto_msgs/VehicleMotionReport`       | values such as vehicle speed measured by on-board sensors    |
| Vehicle System Report  | `autoware_auto_msgs/VehicleSystemReport`       | status of the vehicle system such as blinker or headlight   |


The output to the vehicle depends on each vehicle interface.

| Output (to vehicle)          | Topic(Data Type)                       | Explanation                                 |
| ---------------              | -------------------------------------- | ------------------------                    |
| vehicle control messages     | Depends on each vehicle                | Control signals to drive the vehicle        |



## Vehicle Command Gate


Vehicle Cmd Gate module is responsible for Systematic post-processing.

### Role

Roles of Vehicle Cmd Gate module are as follows.


- Select the command values (Trajectory follow command, Remote manual command, safety command, etc.)
- Reflect engage command to control signal for vehicles
  - Until true command is sent as engage command, Vehicle Cmd Gate module does not pass the input command information as output.
- Apply the maximum speed maximum lateral/longitudinal jerk limit

### Input

- Vehicle motion command from Control and Remote module(`autoware_auto_msgs/VehicleMotionCommand`)
- Vehicle system command from Planning and Remote module(`autoware_auto_msgs/VehicleSystemCommand`)
- Engage Commands(`std_msgs/Bool`)


### Output

- vehicle motion command for vehicles (`autoware_auto_msgs/VehicleMotionCommand`)
- vehicle system command for vehicles (`autoware_auto_msgs/VehicleSystemCommand`)



## Vehicle Interface

### Role

To convert Autoware control messages to vehicle-specific format, and generate vehicle status messages from vehicle-specific format. Depending on the vehicle, a type A or B interface must be implemented.

### Input

- Vehicle Motion Command (`autoware_auto_msgs/VehicleMotionCommand`) (for type A)
  - desired vehicle motion including target velocity, acceleration, steering angle, steering angle velocity, gear shift, and emergency.
- Raw Vehicle Motion Command (`autoware_auto_msgs/RawVehicleMotionCommand`) (for type B)
  - desired vehicle motion including target throttle pedal, brake pedal, steering angle, steering angle velocity, gear shift, and emergency.
- Vehicle System Command (`autoware_auto_msgs/VehicleSystemCommand`)
  - desired vehicle system state includes headlight, wiper, gear, mode, hand_brake, and horn.

### Output


- vehicle motion command (`autoware_auto_msgs/VehicleMotionReport`)
  - includes steering angle, and velocity.
- vehicle system command (`autoware_auto_msgs/VehicleSystemReport`)
  - includes fuel, blinker, headlight, wiper, gear, mode, hand_brake, horn. 
  - (**TBD**: The mode must be implemented. Others are optional.)

NOTE: Lane driving is possible without the optional part. Design vehicle interface according to the purpose.

## Raw Vehicle Cmd Converter

### Role


To convert the target acceleration to the target throttle and brake pedals with the given acceleration map. This node is used only for the case of vehicle type B.

### Input

- Vehicle Command (`autoware_vehicle_msgs/VehicleCommand`)
- Current velocity (`geometry_msgs/TwistStamped`)

### Output

- Raw Vehicle Command (`autoware_vehicle_msgs/RawVehicleCommand`)
  - includes target throttle pedal, brake pedal, steering angle, steering angle velocity, gear shift, and emergency.
