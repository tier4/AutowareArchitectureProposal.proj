Localization
=============

# Overview

The localization stack has a role to recognize where ego vehicle is in local coordinates on reference map with sensor and map information. Additionally this stack estimates twist of ego vehicle for precise velocity planning and control.

## Role

There are two main roles of Localization stack:

- Estimation of a self-position and a self-twist
- Integration of pose and twist information estimated by multiple sensors for robustness

## Input

| Input          | Data Type                                  |
| -------------- | ------------------------------------------ |
| LiDAR          | `sensor_msgs::PointCoud2`                  |
| GNSS           | `geometry_msgs::PoseWithCovarianceStamped` |
| IMU            | `sensor_msgs::Imu`                         |
| Pointcloud Map | `sensor_msgs::PointCoud2`                  |
| Vehicle CAN    | `geometry_msgs::TwistStamped`              |

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

| Output        | Topic (Data Type)                                                                | Use Cases of the output       |
| ------------- | -------------------------------------------------------------------------------- | ----------------------------- |
| Vehicle Pose  | `/tf` <br> (`tf2_msgs/TFMessage`)                                                | Perception, Planning, Control |
| Vehicle Twist | `/localization/twist`<br>(`geometry_msgs/TwistStamped`) | Planning, Control             |

## Use Cases

| Use Case                                             | Requirement in `Localization`      | Output                 | How it is used                                                                                                                                                     |
| --------------------------------------------------- | ---------------------------------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Passing intersection<br>with traffic lights         | Self pose on the map               | Perception             | To detect traffic lights associated  with the lane<br>where ego vehicle is in the camera image                                                                     |
| Changing lane                                       | Self pose on the map               | Perception<br>Planning | To predict object motion on the lane<br>with lane information<br><br>To recognize drivable area based on lane information<br>and the position where ego vehicle is |
| Stopping at crosswalk<br>when pedestrian is walking | Self pose on the map               | Perception             | To recognize where crosswalk is<br>based on ego vehicle position and map information                                                                               |
| Reaching a goal<br>by driving on lanes              | Self pose on the map               | Planning               | To plan the global path from the position where ego vehicle is to<br>a goal with lane information                                                                  |
| Driving<br>with following speed limits              | Self pose on the map<br>Self twist | Planning               | To recognize speed limit on the lane<br>where ego vehicle is<br><br>To plan target velocity<br>based on velocity of ego vehicle and speed limit                    |
| Driving<br>on the target lane                       | Self pose on the map<br>Self twist | Control                | To calculate target throttle/brake value and steering angle<br>based on pose and twist of ego vehicle and target trajectory                                        |

# Design

The localization stack provides indispensable information to achieve autonomous driving. Therefore, it is not preferable to depend on only one estimator component for output of the localization stack. We insert pose twist fusion filter after pose and twist estimator to improve robustness of the estimated pose and twist. Also, developers can easily add new estimator based on another sensor, e.g. camera based visual SLAM and visual odometry, into the localization stack.  The localization stack should output the transformation from map to base_link as /tf to utilize its interpolation system. 

![Localization_component](/design/img/Localization_overview.svg)

## Pose estimator

### Role
Pose estimator is a component to estimate ego vehicle pose which includes position and orientation. The final output should also include covariance, which represesents the estimator's confidence on estimated pose. A pose estimator could either be estimate pose on local map, or it can estimate absolute pose using global localizer. The output pose can be publihsed in any frame as long as /tf is provided to project into the "map" frame.

### Input

- LiDAR
- GNSS
- Camera (not implemented yet)
- Pointcloud Map

### Ouput
- Pose with Covariance
- Pose Estimator Diagnostics


## Twist Estimator

Twist estimator is a component to estimate ego vehicle twist for precise velocity planning and control. The  x-axis velocity and z-axis angular velocity in vehicle twist is mainly considered. These values are preferable to be noise-free and unbiased.

### Input

- Vehicle CAN
- IMU
- Camera (not implemented yet)

### Output

- Twist with Covariance

## Pose Twist Fusion Filter

### Role

Pose Twist Fusion Filter is a component to integrate the poses estimated by pose estimators and the twists estimated by twist estimators. This assumes sequential Bayesian Filter, such as EKF and particle filter, whch calculates vehicle's pose and twist probabilistically. This should also achieve following funcitons:
* smoothing of estimated pose (see [TF.md](/design/TF.md))
* outlier rejection of inputs based on previously calucated pose and it's covariance (see [TF.md](/design/TF.md))
* time delay compensation in case pose estimators take time to calculate pose

### Input

- Initial Pose
- Pose with Covariance
- Twist with Covariance

### Output

- Ego Vehicle Pose (/tf from map frame to base_link frame)
- Ego Vehicle Twist

# References
TBU
