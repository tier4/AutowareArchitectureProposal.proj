Sensing
=========

# Overview 

For autonomous driving, a vehicle needs to know an environment surrounding itself.
A sensing stack has a role to correct the environment information and form it appropriately.

# Use Cases

![Sensing_overview](/img/Sensing_overview.svg)

This sensing stack has 2 main roles:

- Conversion of sensing data to ROS message
- Common preprocessing of sensing data (if forming is needed)

Various input modalities can be considered, including:

- LiDAR
- Camera
- GNSS
- IMU

After prosessing, row / formed data and ROS messages are output.
These output are widely used in other stacks:

- Formed pointcloud:
	- Localization (Pose estimation)
	- Perception (Detection)
	- Planning (Costmap generation)
- Camera image:
	- Perception (Detection)
	- Localization (Pose estimation)
- GNSS data:
	- Localization (Pose estimation)
- IMU data:
	- Localization (Twist estimation)

## High-level use cases

### Conversion of sensing data to ROS message

Through drivers and converters for each sensors, raw sensing data is comverted to ROS message format.

### Common preprocessing of sensing data (if forming is needed)

For pointcloud data, some preprocessings are required before the data is utilized on other stacks.

For example, we think preprocessings below will be commonly needed.

- Ground filter : Removes pointclouds correspond to the ground.
- Outlier filter : Removes outlier pointclounds which are appeared due to leaves, insects, and so on.
- Concat filter : Concatenates pointclouds come from some LiDARs.
- Ego-vehicle cropping filter : Removes pointclouds correspond to the ego-vehicle.
- Distortion correction : Corrects the distortion of the pointclouds due to observation time gaps.

## Input use cases / Sensors

Following sensors are considered:

- LiDAR
- Camera
- GNSS
- IMU

## Output use cases

The outputs can be used to many stacks in the autonomous driving.

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

# Requirements

A sensing implementation must satisfy a requirement in order to be compatible with the aforementioned use cases.

- Provide the neatly arrenged data

# Mechanisms

The mechanisms to satisfy a repuirement above:

- Specific drivers are needed for each sensor
- A mechanism to remove the noise and the distortion from raw data is needed

# Design

In order to support the above stated use cases and derived requirements, a decomposition of the sensing stack is proposed below.

## Components

We defined following componentes in sensing stack. Depending on the use case and capabilities of various components, only some subset of the components may be needed.

![Sensing_component](/img/Sensing_component.svg)

### Drivers

- LiDAR driver
- Camera driver
- gnss driver
- imu driver

### Preprocessor

- Pointcloud
	- Ground filter
	- Outlier filter
	- Concat filter
	- Ego-vehicle cropping filter
	- Distortion correction
- GNSS
	- MGRS conversion

#### LiDAR driver

TBU

#### Camera driver

TBU

#### gnss driver

TBU

#### imu driver

TBU

#### Ground filter

TBU

#### Outlier filter

TBU

#### Concat filter

TBU

#### Ego-vehicle cropping filter

TBU

#### Distortion correction

TBU

#### MGRS conversion

TBU

# References

TBU

