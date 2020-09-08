# Vehicle

# Overview

Vehicle stack is an interface between Autoware and vehicle. This layer converts signals from Autoware to vehicle-specific, and vice versa.
This module needs to be designed according to the vehicle to be used. How to implement a new interface is described [below.](#how-to-design-a-new-vehicle-interface)



## Role

There are two main roles of Vehicle stack:

- **Conversion of Autoware commands to a vehicle-specific format**
- **Conversion of vehicle status in a vehicle-specific format to Autoware messages**

## Assumption

It is assumed that the vehicle has one or both of the following control interfaces.

**Type A. target velocity or acceleration interface.**

**Type B. target throttle and brake pedals interface.**

The use case and requirements change according to this type.


## Use Cases

Vehicle stack supports the following use cases.

 - Speed control with desired velocity or acceleration (for type A only)
 - Speed control with desired throttle and brake pedals (for type B only)
 - Steering control with desired steering angle and/or steering angle velocity (for both)
 - System control for headlight, wiper, gear, mode, hand_brake, and horn (for both)


## Requirement

To achieve the above use case, the vehicle stack requires the following conditions.

**Speed control with desired velocity or acceleration (for type A)**
 - The vehicle can be controlled by the target velocity or acceleration.
 - The input vehicle command includes target velocity or acceleration.
 - The output to the vehicle includes desired velocity or acceleration in a vehicle-specific format.

**Speed control with the desired throttle and brake pedals (for type B)**
 - The vehicle can be controlled by the target throttle and brake pedals.
 - The input vehicle command includes target throttle and brake pedals for the desired speed.
 - The output to the vehicle includes desired throttle and brake pedals in a vehicle-specific format.

**Steering control with the desired steering angle and/or steering angle velocity**
 - The vehicle can be controlled by the target steer angle and/or steering angle velocity.
 - The input vehicle command includes the target steering angle and/or target steering angle velocity.
 - The output to the vehicle includes the desired steering angle and/or steering angle velocity in a vehicle-specific format.


**System control**
 - The vehicle can be controlled by the system command including
   - blinker
   - headlight
   - wiper
   - gear
   - mode
   - hand_brake
   - horn
 - The input system command includes the desired value.
 - The output to the vehicle includes the target system comand in a vehicle-specific format.


## Input

The input to Vehicle stack:

| Input                      | Topic(Data Type)                                                   | Explanation |
| ----------------------     | ------------------------------------------------------------------ | ----------- |
| Vehicle Motion Command     | `autoware_auto_msgs/VehicleMotionCommand`                          | Table Below |
| Vehicle System Command     | `autoware_auto_msgs/VehicleSystemCommand`                          | Table Below |
| Raw Vehicle Motion Command | `autoware_auto_msgs/RawVehicleSystemCommand`                       | Table Below |

The detailed contents in Vehicle Motion / System Command are as follows.

**VehicleMotionCommand**

```
builtin_interfaces/Time stamp
Float32 velocity       # desired velocity for the baselink
Float32 acceleration   # desired acceleration for the baselink
Float32 steering       # desired steering angle
Float32 steering_rate  # desired steering anglular velocity
```


**VehicleSystemCommand**

```
builtin_interfaces/Time stamp
uint8 blinker
uint8 headlight
uint8 wiper
uint8 gear
uint8 mode
bool hand_brake
bool horn
```


**RawVehicleMotionCommand**

```
builtin_interfaces/Time stamp
Float32 throttle
Float32 brake
Float32 steering
Float32 steering_rate
```

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

**VehicleMotionReport**

```
builtin_interfaces/Time stamp
Float32 velocity
Float32 steering
```


**VehicleSystemReport**

```
builtin_interfaces/Time stamp
uint8 fuel          # 0 to 100
uint8 blinker
uint8 headlight
uint8 wiper
uint8 gear
uint8 mode          # Autonomous / Manual / Disengaged / NotReady
bool hand_brake
bool horn
```

# Design

For vehicles of the type controlled by the target velocity or acceleration (type A)

![Vehicle_design_typeA](/design/img/VehicleInterfaceDesign1_reviewed.png)


For vehicles of the type controlled by the target throttle and brake pedals (type B)

![Vehicle_design_typeB](/design/img/VehicleInterfaceDesign2_reviewed.png)

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

# How to design a new vehicle interface

**For type A**

Create a module that satisfies the following two requirements
 - Receives `autoware_vehicle_msg/VehicleCommand` and sends control commands to the vehicle.
 - Converts the information from the vehicle, publishes vehicle speed to Autoware with `geometry_msgs/TwistStamed`.

For example, if the vehicle has an interface to be controlled with a target velocity, the velocity in `autoware_vehicle_msg/VehicleCommand` is sent to the vehicle as the target velocity. If the vehicle control interface is steering wheel angle, it is necessary to convert steering angle to steering wheel angle in this vehicle_interface.



**For type B**

Since `autoware_vehicle_msg/VehicleCommand` contains only the target velocity and acceleration, you need to convert these values for the throttle and brake pedal interface vehicles. In this case, use the `RawVehicleCmdConverter`. The `RawVehicleCmdConverter` converts the target acceleration to the target throttle/brake pedal based on the given acceleration map. You need to create this acceleration map in advance from vehicle data sheets and experiments.


With the use of `RawVehicleCmdConverter`, you need to create a module that satisfies the following two requirements
 - Receives `autoware_vehicle_msg/RawVehicleCommand` and sends control commands to the vehicle.
 - Converts the information from the vehicle, publishes vehicle speed to Autoware with `geometry_msgs/TwistStamed`.


**How to make an acceleration map (for type B)**

When using the `RawVehicleCmdConverter` described above, it is necessary to create an acceleration map for each vehicle. The acceleration map is data in CSV format that describes how much acceleration is produced when the pedal pressed in each vehicle speed range. You can find the default acceleration map data in `src/vehicle/raw_vehicle_cmd_converter/data` as a reference. In the CSV data, the horizontal axis is the current velocity [m/s], the vertical axis is the vehicle-specific pedal value [-], and the element is the acceleration [m/ss] as described below.

![Vehicle_accel_map_description](/design/img/VehicleAccelMapDescription.png)


This is the reference data created by TierIV with the following steps.

  - Press the pedal to a constant value on a flat road to accelerate/decelerate the vehicle.
  - Save IMU acceleration and vehicle velocity data during acceleration/deceleration.
  - Create a CSV file with the relationship between pedal values and acceleration at each vehicle speed.

After your acceleration map is created, load it when `RawVehicleCmdConverter` is launched (the file path is defined at the launch file).

**Control of additional elements, such as turn signals**

If you need to control parts that are not related to the vehicle drive (turn signals, doors, window opening and closing, headlights, etc.), the vehicle interface will handle them separately. The current Autoware supports and implements only turn signals.


# いろいろ

- 車両インターフェースは安全を考慮して基本的にbaseクラスを継承して設計する
  - しかし、この部分が提供されない可能性も踏まえ、エンゲージ処理、速度制約などはgateでも対応する。
  - つまりvehicle_interfaceとcommand_gateでは同じ処理が走る。
- system commandのトピック型は基本形として情報をまとめたものを用意する
  - 他のトピックを追加する場合は（例えばドア開閉コマンドなど）、別トピックとして用意し、別途vehicle_interfaceに口を用意する。systemCommandの改変は頻繁には行わない
  - これによって、プロジェクト間でのトピックの流用を可能にする
- vehicle_interfaceは車両との接続のみを目的とし、PIDのようなアルゴリズムはinterface外部で対応する
  - これはOEMなどからのブラックボックスな車両インターフェースの統合のためである。
  - （**TBD**ティアフォーから例を出す）

# AutowareAutoからの変更点

- vehicle command gateの追加
  - 主に複数コマンド、およびブラックボックスの車両インターフェースへの対応
- HighLevelVehicleCommandの削除
- 後輪ステア角の指示値の削除
- the odometry, outout of the vehicle module, is replaced to the `VehicleMotionReport`.

# AutowareArchitectureProposalからの変更点

- Combine system related commands into one topic (`VehicleSystemCommand/Report`)
