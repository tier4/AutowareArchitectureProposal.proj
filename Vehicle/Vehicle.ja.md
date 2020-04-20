# Vehicle

# Overview

Vehicle stack is an interface between Autoware and vehicle. This layer converts signals from Autoware to vehicle-specific, and vice versa. 
Basically, this part needs to be designed according to the vehicle to be used. How to implement a new interface is described [here.](# How to design a new vehicle interface
)



## Role

There are two main roles of Vehicle Stack:

- **Conversion of Autoware commands to a vehicle specific format**
- **Conversion of vehicle status in a vehicle specific format to Autoware messsages**


## Assumption

It is assumed that the vehicle has one of the following control interfaces.

**Type A. target velocity or acceleration interface.**

**Type B. target throttle and brake pedals interface.**

The use case and requirements change according to this type.


## Use Case

Vehicle stack supports the following use cases.

 - Speed control with desired velocity or acceleration (for type A only)
 - Speed control with desired throttle and brake pedals (for type B only)
 - Steering control with desired steering angle or/and steering angle velocity (for both)
 - Shift control (for both)
 - Turn signal control (for both)


## Requirement

In order to achieve above use case, vehicle stack require the following conditions.

**Speed control with desired velocity or acceleration (for type A)**
 - The vehicle can be controlled by the target velocity or acceleration.
 - The input vehicle command includes target velocity or acceleration. 
 - The output to vehicle includes desired velocity or acceleration in a vehicle-specific format.

**Speed control with desired throttle and brake pedals (for type B)**
 - The vehicle can be controlled by the target throttle and brake pedals.
 - The input vehicle command includes target throttle and brake pedals for a desired speed. 
 - The output includes desired throttle and brake pedals in a vehicle-specific format.

**Steering control with desired steering angle or/and steering angle velocity**
 - The vehicle can be controlled by the target steer angle or/and steering angle velocity.
 - The input vehicle command includes target steering angle or/and target steering angle velocity. 
 - The output to vehicle includes desired steering angle or/and steering angle velocity in a vehicle-specific format.


**Shift control**
 - The vehicle can be controlled by the target shift mode.
 - The input vehicle command includes a desired shift.
 - The output to vehicle includes desired shift in a vehicle-specific format.


**Turn signal control**
 - The vehicle can be controlled by the target turn signal mode.
 - The input vehicle command includes a desired turn signal.
 - The output to vehicle includes desired turn signal in a vehicle-specific format.

## Input

The input to Vehicle stack:

| Input           | Topic(Data Type)                                                   | Explanation |
| --------------- | ------------------------------------------------------------------ | ----------- |
| Vehicle Command | `/control/vehicle_cmd`<br>(`autoware_vehicle_msgs/VehicleCommand`) | Table Below |

The detailed contents in Vehicle Command are as follows.

| Input                  | Data Type        | Explanation                            |
| ----------------------- | ---------------- | -----------                            |
| Velocity                | std_msgs/Float64 | Target veocity [m/s]                   |
| Acceleration            | std_msgs/Float64 | Target acceleration [m/s2]             |
| Steering angle          | std_msgs/Float64 | Target steering angle [rad]            |
| Steering angle velocity | std_msgs/Float64 | Target steering angle velocity [rad/s] |
| Gear shifting command   | std_msgs/Int32   | Target Gear shift                      |
| Emergency command       | std_msgs/Int32   | Emergency status of Autoware           |



### Output

There are two types of outputs from Vehicle stack : vehicle status to Autoware and a control command to the vehicle.

The table below summarizes the output from Vehicle stack:

| Output (to Autoware)          | Topic(Data Type)                                                      | Explanation                                 |
| ---------------               | ------------------------------------------------------------------    | ------------------------                    |
| velocity status               | `/vehicle/status/twist`<br>(`geometry_msgs/TwistStamped`)             | vehicle velocity status to Autoware [m/s]   |
| steering status (optional)    | `/vehicle/status/steering`<br>(`autoware_vehicle_msgs/Steering`)      | vehicle steering status to Autoware [rad]   |
| Shift status (optional)       | `/vehicle/status/Shift`<br>(`autoware_vehicle_msgs/ShiftStamped`)     | vehicle shift to Autoware [-]               |
| Turn signal status (optional) | `/vehicle/status/turn_signal`<br>(`autoware_vehicle_msgs/TurnSignal`) | vehicle turn signal status to Autoware [m/s]|


The output to the vehicle depends on each vehicle interfaces.

| Output (to vehicle)          | Topic(Data Type)                                                      | Explanation                                 |
| ---------------              | ------------------------------------------------------------------    | ------------------------                    |
| vehicle control messages     | Depends on each vehicle                                               | Control signals to drive the vehicle        |




# Design

For vehicles of the type controlled by the target velocity or acceleration (type A)

![Control_component](/img/Vehicle_interface_design_1.png)


For vehicles of the type controlled by the target throttle and brake pedals (type B)

![Control_component](/img/Vehicle_interface_design_2.png)


## Vehicle Interface 

### Role

To convert Autoware control messages to vehicle-specific format, and generate vehicle status messages from vehicle-specific format.

### Input

- Vehicle Command (type A only)
  - includes target velocity, acceleration, steering angle, steering angle velocity, gear shift and emergency.
- Raw Vehicle Command (type B only)
  - includes target throttle pedal, brake pedal, steering angle, steering angle velocity, gear shift and emergency.
- Turn signal (optional)

### Output

- Velocity status
- Steering status (optional)
- Shift status (optional)
- Turn signal status (optional)

NOTE: Lane driving is possible without the optional part. Design vehicle interface according to the purpose.

## Raw Vehicle Cmd Converter

### Role

事前に与えた加速度マップのデータを用いて、目標加速度から目標アクセル/ブレーキペダルへの変換をします。車両type Bの場合はこのノードを利用します。

### Input

- Vehicle Command
- Current velocity

### Output

- Raw Vehicle Command
  - includes target throttle pedal, brake pedal, steering angle, steering angle velocity, gear shift and emergency.

# How to design a new vehicle interface

**基本方針**

以下の2つの要求を満たすモジュールを作成してください。
 - `autoware_vehicle_msg/VehicleCommand` を受け取り、制御コマンドを車両へ伝える
 - 車両からの情報を変換し、車両速度を`geometry_msgs/TwistStamepd` に変換して出力する

例えば、車両が目標速度を与えて駆動するインターフェースになっている場合は、`autoware_vehicle_msg/VehicleCommand` に含まれているvelocityを目標速度として車両へ伝えます。車両制御IFがsteering wheel angleの場合は、このinterfaceでsteering angle -> steering wheel angle への変換を行う必要が有ります。

以下は付加的な要素になります。

**方向指示器などの付加要素の制御**

車両の駆動とは関係ない部分（方向指示器、ドア、窓の開閉、ヘッドライト）などの制御が必要な場合は、vehicle interfaceで個別に対応します。
現状のAutowareとしてサポート・実装しているのは方向指示器のみです。

**車両制御IFがペダル値の場合(for type B)** 

` autoware_vehicle_msg/VehicleCommand` には目標速度・加速度のみしか含まれていないため、車両がアクセル・ブレーキ駆動の場合はこれらの値を変換する必要が有ります。これには各Interfaceで個別に実装してもらう方法と、RawVehicleCmdConverterを利用する方法があります。

RawVehicleCmdConverterを利用する場合は、ノードの構成は「目標アクセル・ブレーキペダルによって制御されるタイプの車両の場合」のデザイン図で示したようになります。
RawVehicleCmdConverterは与えられた加速度マップをもとに目標加速度と目標ペダルの変換を行います。車両のデータシートや実験などから加速度マップを作成する必要が有ります。

**加速度マップの作成方法**

上記で述べたRawVehicleCmdConverterを使用する場合は、各車両に応じた加速度マップの作成が必要です。加速度マップは各車速域でペダルを踏んだ時にどのような加速度が出るかを示したデータであり、csv形式で提供されます。`src/vehicle/raw_vehicle_cmd_converter/data` の中にデフォルトの加速度マップのデータが入っています（横軸が現在速度、縦軸が車両固有のペダル値、要素がその時の加速度）。これはティアフォーが作成したreferenceデータであり、平坦な道で一定ペダルを無み込んだ時のimuのデータから作成されたものです。（このデータは強く車両に依存するため、この値を直接使うことはできません。）これを参考に、各車両の加速度マップを作成し、RawVehicleCmdConverterのlaunchファイルで読み込んでください。




# 以下コメント：

Outputが2系統ある（vehicle specific command & vehicle status）ので、ここを明確に分類して書いてあげる方がわかりやすいのかなと思いました。
（Use caseのところとか、Tableのところとか）

三宅さんの仰るとおり、現状異なる車両のコントローラ（といよりドライバ？）の仕様を想定していて、それぞれに合わせたUseCaseRequirementが分かるようになっていると良いと思います。
なので、UseCaseの前にAssumptionという項目を作って、
「下記いずれかの車両を想定しています。
A. 目標速度・加速度によって制御されるタイプの車両
B. 目標アクセル・ブレーキペダルによって制御されるタイプの車両
」
ということを一番最初に述べておいて、それぞれについてUseCaseRequirementが整理されていると良いかと思います。

Designの図のtypo (Interfae -> Interface)
Designの１個めと２個めの図が両方VehicleInterfaceという書き方をしているのですが、Input/Outputが違うのに同じモジュール名になっている。上であげた車両タイプにA,Bと名前をつけて Vehicle Interface (Type A) と Vehicle Interface (Type B) というように別名になるようにしたほうが良いかもです

僕がさっき言ってたのは、車両センサのInputと車両への制御指令の話でしたが、VehcleCmdとRawVehicleCmdの方も、満留さんのご提案する書き方にするのがいいと思います！

A/Bは「両方出ているので好きな方を選んでね」、くらい書いておくと親切かと。

