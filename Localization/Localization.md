Localization
=============

# Overview
The localization stack has a role to recognize where ego vehicle is in local coordinates on reference map with sensor and map information.

## Role
There are two main roles of Localization stack:
- Integration of each sensor data
- Estimation of a self-position and a self-velocity

## Input

| Input Type  | Data Type                                            |
|-------------|------------------------------------------------------|
| LiDAR       | `sensor_msgs::PointCoud2`, ``                        |
| GNSS        | `geometry_msgs::PoseWithCovariance`                  |
| IMU         | `sensor_msgs::Imu`                                   |
| Map         | `autoware_lanelet2_msgs::MapBin`                     |
| Vehicle CAN | `geometry_msgs/TwistWithCovariance twist_covariance` |

### Sensors

Multiple sensor information described below is considered.   

- Lidar

  Point cloud resistration method such as ICP, NDT estimates ego vehicle pose by refining the relative transformation between 3D point cloud from lidar with reference point cloud map.

- GNSS

  The pose information recieved from GNSS is projected to local coordinates on reference map.
  Intial pose is estimated by refining the projected GNSS pose.

- Vehicle CAN

  Vehicle CAN outputs useful information such as vehicle velocity, steering wheel angle to estimate vehicle twist.
  We adapt vehicle velocity from vehicle CAN as vehicle twist.

- IMU

  Angular velocity recieved from IMU has a small bias.
  We adopt angular velocity from IMU as vehicle twist.

- Camera

  We do not implement camera based pose or twist estimator.
  You can easily integrate image based estimator such as visual odometry, visual slam into the localization stack.

### Reference Map

- Point Cloud Map
  
## Output

| Output Type         | Data Type                                          | Use Cases of the output         |
|---------------------|----------------------------------------------------|---------------------------------|
| Vehicle Pose      | `autoware_perception_msgs::DynamicObjectArray`     | Planning                        |
| Vehicle Twist | `autoware_perception_msgs::TrafficLightStateArray` | Planning                        |
| Diagnostics | `autoware_perception_msgs::TrafficLightStateArray` | Planning                        |

- Ego Vehicle Pose
- Ego Vehicle Twist
- Diagnostics

# Module Design
TBU

![Localization_component](/img/Localization_component.svg)

## Pose estimator
* Role

  estimate initial pose of ego vehicle

  estimate relative pose of ego vehicle based on estimated initial pose

* Input
  * Lidar
  * GNSS
  * Camera (not implemented yet)
  * Point Cloud Map
* Ouput
  * Initial Pose
  * Pose with Covariance
  * Pose Estimator Diagnostics

* Implemented Feature
  * Pose Initializer

    - Automatic initial self position estimation by GNSS + Monte-Carlo method

  * NDT scan matcher
    
    - Uses an estimated value of EKF as an initial position of the scan matching i.e. if scan matching was failed, localization can be returned
    
    - Performance and accuracy are improved (Open-MP implementation, accuracy improvement of the initial position, improvement of the  gradient method, distortion correction of pointclouds, and etc.)

  * Scan matching failure judgement
    
    - Monitors statuses of scan matching based on a score

    - If score is lower than a threshold, an estimated result isn’t output
    


  
## Twist Estimator 
* Role
  
  estimate ego vehicle twist i.e. velocity and angular velocity of ego vehicle.

* Input
  * Vehicle CAN
  * IMU
  * Camera (not implemeted yet) 
  
* Ouput
  * Twist with Covariance
  * Twist Estimator Diagnostics

* Impremented Feature
  * IMU-VehicleTwist fusion
    * Uses a translation velocity of CAN and yaw rate of IMU

## Pose Twist Fusion Filter
* Role

  integrate the poses estimated by pose eatimator and the twists estimated by twist estimator

* Input
  * Initial Pose
  * Pose with Covariance
  * Twist with Covariance

* Ouput
  * Ego Vehicle Pose (/tf from map frame to base_link frame)
  * Ego Vehicle Twist
  * Pose Twist Fusion Filter Diagnostics

* Implemented Feature
  * EKF localizer
    * Integrates the estimated self position of the scan matching and the twist of CAN＋IMU
    * If scan matching breaks down, the vehicle can drive a certain distance with odometry only

## Localizer Diagnostics
* Role

  aggeregate diagnostics information from each localization module to stop autonomous driving system safely

  when the estimated pose or twist do not provide assuarance sufficient for autonomous driving.

* Input
  * Pose Estimator Diagnostics
  * Twist Estimator Diagnostics
  * Pose Twist Fusion Filter Diagnostics

* Ouput
  * Localization Diagnostics

# References
TBU
