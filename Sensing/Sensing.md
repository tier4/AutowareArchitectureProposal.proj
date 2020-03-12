Sensing
=========

# Overview 
For autonomous driving, a vehicle needs to be aware of its surrouding environment.
Sensing stack collects the environment information through various sensors and format/manipulate data appropriately to be used by other stacks.

![Sensing_overview](/img/Sensing_overview.svg)


## Role
There are two main roles of Sensing stack:
- **Conversion of sensing data to ROS message**  
  Sensing stack unifies the output format of sensors so that following AD stacks (e.g. percpetion) do not have to be aware of the hardware to use sensor data.
- **Preprocessing of sensing data**  
  Raw data from sensors usually contains errors/noise due to hardware limitations. Sensing stack is responsible for removing such inaccuracies as much as possible before distributing sensor outputs to following stacks. Sensing stack may also do extra restructuring/formatting of data for so that there will be no duplicate data preprocessing done in different stacks.

## Input
Sensing stack supports following sensors:
- LiDAR
- Camera
- GNSS
- IMU

Inputs from a sensor can be in various formats(USB, CAN bus, tcp/ip, etc.) as it depends on hardware specifications.
Autoware sets [reference platform](link_to_reference_platform) and provides drivers for supported sensors.
Although Autoware does not limit the use of other sensors, it is user's responsibility to prepare ROS sensor driver for the sensor in such case.

## Output
The table below sumarizes the output from Sensing stack:
| Sensor Type | Data Type                                                                        | Use Cases of the output    |
| ----------- | -------------------------------------------------------------------------------- | -------------------------- |
| LiDAR       | sensor_msgs::PointCloud2                                                         | Localization (Pose estimation)<br>Perception (Object Recognition)<br>Planning (Costmap generation) |
| Camera      | sensor_msgs::Image                                                               | Perception (Traffic Light Recognition, Object Recognition)<br>Localization (Pose estimation)       |
| GNSS        | sensor_msgs::NavSatFix (Raw)<br>geometry_msgs::PoseWithCovariance (preprocessed) | Localization (Pose estimation)                                                                     |
| IMU         | sensor_msgs::Imu                                                                 | Localization (Twist estimation)                                                                    |

For each of the sensors, there will be two types of outputs: raw data and preprocessed data. Note that preprocessed data might be same as raw data if no preprocessing is required. All other AD stacks should be subscribing to preprocessed data in most cases, and raw data should only be used for debugging purposes such as visualization and data recording.

In general, the final output of Sensing stack should be in sensor_msgs type which is de facto standard in ROS systems. This allows developers to use default ROS tools such as RVIZ to visualize outputs. One of the exception is GNSS data, which is published as geometry_msgs/PoseWithCovariance instead of sensor_msgs/NavSatFix. We came to conclusion that PoseWithCovariance message essentially contains the same information and is more convenient for Localization stack(the main user of the data) since localization is done in Cartesian coordinate.


# Design

In order to support the above use cases and output requirements, Sensing stack is decomposed as below.
Depending on the use case and hardware configuration of the vehicle, users may choose to use a subset of the components stated in the diagram.
![Sensing_component](/img/Sensing_component.svg)

The components are separated into drivers and preprocessors. Drivers are responsible for converting sensor data into ROS message and modification of the data during conversion should be minimal. It is preprocessors' responsibility to manipulate sensor data for ease of use.

## Drivers

### LiDAR driver
TBU
### Camera driver
TBU
### GNSS driver
TBU
### IMU driver
TBU

## Preprocessors

### Pointcloud

2 types of pointclouds are output through the preprocessor:

- pointcloud including ground points : `~output/pointcloud`
- pointcloud without ground points : `~output/no_ground/pointcloud`

#### Pointcloud including ground points

This pointcloud can be used for "costmap generation" in the planning stack.
In the costmap generation process, the pointcloud is combined with a map data, a predicted object information and an estimated current position.


#### Pointcloud without ground points

This pointcloud can be used for "pose estimater" in the localization stack and "detection" in the perception stack.
In the pose estimation process, the pointcloud is compared with the pointcloud map and the result of the comparison is used for the current position estimation.
In the detection process, the pointcloud is segmented and combined with a detection result of camera images and a costmap is estimated.

### Camera image

The camera image is output as `~output/image_raw`.
The output can be used for "image detection" in the perception stack and "pose estimater" in the localization stack.
In the imange detection process, objects are detected on the image with some detection algorithms.
In the pose estimation process, the image can be used as an optional information to estimate a current position of the ego-vehicle.

### GNSS

The GNSS data is output as `~output/pose_with_covariance`.
The output can be used for "pose estimater" and "twist estimater" in the localization stack.
In the pose estimation process, the data is utilized for the pose initialization of the current ego-vehicle.
In the twist estimation process, the data is combined with the imu data and a twist data with covariance from the vehicle, and the current velocity of the ego-vehicle is estimated.

### IMU

The IMU data is output as `~output/imu_raw`.
The output can be used for "twist estimater" in the localization stack.
In the twest estimation process, the data is combined with the GNSS data and a twist data with covariance, and the current velocity of the ego-vehicle is estimated.


# References

TBU

