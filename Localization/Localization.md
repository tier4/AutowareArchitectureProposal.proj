Localization
=============

# Overview

The localization stack has a role to recognize where ego vehicle is in local coordinates on reference map with sensor and map information. Additionally this stack estimates twist of ego vehicle for precise velocity planning and control.

## Role

There are two main roles of Localization stack:

- Estimation of a self-position and a self-twist
- Integration of pose and  twist information estimated by multiple sensors for robustness

## Input

| Input Type     | Data Type                                            |
|----------------|------------------------------------------------------|
| LiDAR          | `sensor_msgs::PointCoud2`                            |
| GNSS           | `geometry_msgs::PoseWithCovarianceStamped`           |
| IMU            | `sensor_msgs::Imu`                                   |
| Pointcloud Map | `sensor_msgs::PointCoud2`                            |
| Vehicle CAN    | `geometry_msgs::TwistStamped`                        |

### Sensors

Multiple sensor information described below is considered.

- LiDAR

  Pointcloud registration method such as ICP, NDT estimates ego vehicle pose by refining the relative transformation between 3D point cloud from lidar with reference pointcloud map.

- GNSS

  The pose information received from GNSS is projected to local coordinates on reference map. Initial pose is estimated by refining the projected GNSS pose.

- IMU

  Angular velocity received from IMU has a small bias. We adopt angular velocity from IMU as vehicle twist.

- Vehicle CAN

  Vehicle CAN outputs useful information such as vehicle velocity, steering wheel angle to estimate vehicle twist. We adapt vehicle velocity from vehicle CAN as vehicle twist.

- Camera

  We do not implement camera based pose or twist estimator. You can easily integrate image based estimator such as visual odometry, visual slam into the localization stack.

### Reference Map

- Pointcloud Map
  
## Output

| Output Type   | Data Type                         | Use Cases of the output         |
|---------------|-----------------------------------|---------------------------------|
| Vehicle Pose  | `tf2_msgs/TFMessage`              | Planning, Control               |
| Vehicle Twist | `geometry_msgs/TwistStamped`      | Planning, Control               |

# Design

The localization stack provides indispensable information to achieve autonomous driving. Therefore it is not preferable to depend on only one estimator component for output of the localization stack. We insert pose twist fusion filter after pose and twist estimator to improve robustness of the estimated pose and twist. Also, developers can easily add new estimator based on another sensor, e.g. camera based visual SLAM and visual odometry, into the localization stack.  The localization stack should output the transformation from map to base_link as /tf to utilize tf interpolation system. 

![Localization_component](/img/Localization_overview.svg)

## Pose estimator

Pose estimator is a component to estimate ego vehicle pose in local coordinates on reference map. We basically adopt 3D NDT registration method for pose estimation algorithm. In order to realize fully automatic localization, initial pose estimation with GNSS is required. In general, iterative methods such as pointcloud registration method require a good initial guess. Therefore it is preferable to utilize pose output of pose twist fusion filter as initial guess of NDT registration. Also, pose estimator should stop publishing pose when the score of NDT matching is less than threshold to avoid misleading wrong estimation.

### Input

- LiDAR
- GNSS
- Camera (not implemented yet)
- Pointcloud Map

### Ouput
- Pose with Covariance
- Pose Estimator Diagnostics


## Twist Estimator

Twist estimator is a component to estimate ego vehicle twist for precise velocity planning and control. The  x-axis velocity and z-axis angular velocity in vehicle twist is mainly considered. Also, this information can be odometry information. These values are preferable to be noise-free and unbiased.

### Input

- Vehicle CAN
- IMU
- Camera (not implemented yet)

### Output

- Twist with Covariance

## Pose Twist Fusion Filter

Pose Twist Fusion Filter is a component to integrate the poses estimated by pose estimator and the twists estimated by twist estimator considering time delay of sensor data. This component improves the robustness, e.g. even when the NDT scan matching  fail, vehicle can keep autonomous driving based on vehicle twist information.

### Input

- Initial Pose
- Pose with Covariance
- Twist with Covariance

### Output

- Ego Vehicle Pose (/tf from map frame to base_link frame)
- Ego Vehicle Twist

# References
TBU
