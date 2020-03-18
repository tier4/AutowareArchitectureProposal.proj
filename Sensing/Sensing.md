Sensing
=========

# Overview 

For autonomous driving, a vehicle needs to be aware of its own state and surrouding environment. Sensing stack collects the environment information through various sensors and manipulates data appropriately to be used by other stacks.

![Sensing_overview](/img/Sensing_overview.svg)


## Role

There are two main roles of Sensing stack:
- **Conversion of sensing data to ROS message**  
  Sensing stack unifies the output format of same type of sensors so that following stacks (e.g. Perception) do not have to be aware of the hardware.
- **Preprocessing of sensing data**  
  Raw data from sensors usually contains errors/noise due to hardware limitations. Sensing stack is responsible for removing such inaccuracies as much as possible before distributing sensor outputs to following stacks. Sensing stack may also do extra restructuring/formatting of data for so that there will be no duplicate data preprocessing done in different stacks.

## Input

### Input Data Types

Since the architecture of Localization stack and Perception stack leaves choices of using different combinations of algorithms, Autoware does not set any requirements about input sensor configurations.

Just as a reference, the recommended sensors from past experience with [Autoware.AI](http://autoware.ai/) is listed below. Note that recommended sensor configuration may change depending on future enhancement of Localization/Perception algorithms. More details about Autoware's reference platform is discussed [here(TBU)](https://gitlab.com/autowarefoundation/autoware-foundation/-/wikis/autonomy-hardware-working-group). Recommended sensors:

- LiDAR
- Camera
- GNSS
- IMU

### Input Data Format

Incoming Sensor data can be in various interface(USB, CAN bus, ethernet, etc.) and in different formats as it depends on hardware specifications. Therefore, sensor drivers are usually made specific to the hardware, and Autoware only provides drivers for supported sensors in [reference platform (TBU)](https://gitlab.com/autowarefoundation/autoware-foundation/-/wikis/autonomy-hardware-working-group). Although Autoware does not limit the use of other sensors, it is user's responsibility to prepare ROS sensor driver for the sensor in such case.

## Output

Since there is no requirements about the sensor configuration of the vehicle, outputs of Sensing stack also varies. However, output message type must be defined for each type of sensors in order to abstract data format from hardware specification, which is one of the roles of Sensing stack.

The table below summarizes the output message for recommended sensors:

| Sensor      | Data Type                                           | Explanation                                                                                                                                                                                                                                                                                        |
| ----------- | --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| LiDAR       | `sensor_msgs::PointCloud2`                          | This contains 3D shape information of surrounding environement as a collection of rasterized points. It is usually used for map matching in Localization stack and object detection in Perception stack.                                                                                                                                                                                                                                                                                        |
| Camera      | `sensor_msgs::Image` <br> `sensor_msgs::CameraInfo` | Camera should provide both Image and CameraInfo topics. Image message contains 2D light intensity information (usually RGB). It is commonly used in Perception (Traffic Light Recognition, Object Recognition) and in Localization(Visual Odometry). By convention, image topic must be published in optical frame of the camera. <br> CameraInfo message contains camera intinsic paramters which is usually used to fuse pointcloud and image information in Perception stack. |
| GNSS        | `geometry_msgs::PoseWithCovariance`                 | This contains absolute 3D pose on earth. The output should be converted into map frame to be used in Localization stack.                                                                                                                                                                                                                                                                                        |
| IMU         | `sensor_msgs::Imu`                                  | This contains angular velocity and accelaration. The main use case is Twist estimation for Localization. The output data may also include estimated orientation as an option.                                                                                                                                                                                                                                                                                                                                                                                                                             |

**rationale**: GNSS data is published as `geometry_msgs::PoseWithCovariance` instead of `sensor_msgs/NavSatFix`. PoseWithCovariance message essentially contains the same information and is more convenient for Localization stack(the main user of the data) since localization is done in Cartesian coordinate.

More sensors will be added into above table after appropriate investigation about how the data will be used in the following stack. In general, the final output of Sensing stack should be in sensor_msgs type which is de facto standard in ROS systems. This allows developers to utilize default ROS tools such as RVIZ to visualize outputs. A reason should be provided if any other data type is used.


# Design

In order to support the above use cases and output requirements, Sensing stack is decomposed as below. Depending on the use case and hardware configuration of the vehicle, users may choose to use a subset of the components stated in the diagram. Convention is that for each sensor, there will be a driver and a preprocessor component.

![Sensing_component](/img/Sensing_component.svg)

The components are separated into drivers and preprocessors. Drivers are responsible for converting sensor data into ROS message and modification of the data during conversion should be minimal. It is preprocessors' responsibility to manipulate sensor data for ease of use.

## Drivers

Driver components act as interface between the hardware and ROS software, and they are responsible for converting sensor data into ROS messages. Although the output of a sensor driver wouldn't be directly used by other stacks, it is usually best practice to record data at input layer of a system for logging and debugging purposes. Thus, driver components should focus on converting raw data to ROS message with minimal modification as much as possible. Ideally, the output message type of driver should be same as final output of Sensing stack, but exceptions are allowed in order to avoid loss of information during conversion or to achieve faster computation time in preprocessor.

### LiDAR driver

#### Input

Raw data from LiDAR. Usually, it is list of range information with time stamp.

#### Output

Output will be converted ROS message data in `sensor_msgs::PointCloud2`. Most of LiDAR driver uses hardware specific configuration parameters, such as angle of projected laser beam, to convert range data into 3D pointcloud. If a single scan of LiDAR contains points with different timestamp, then it must be either published as separate message or accurate timestamp should be specified as an additional field in the message if possible.

### Camera driver

#### Input

Raw data from camera. (Calibration file of the camera that contains intrinsic camera paramter information)

#### Output

The Camera driver should output both `sensor_msgs::Image` message and `sensor_msgs::CameraInfo` message. Although `sensor_msgs::CameraInfo` is not direct output from a camera, it is good practice that these information are published with image since it contains essential information for image processing.

The output can be used for "image detection" in the perception stack and "pose estimater" in the localization stack. In the imange detection process, objects are detected on the image with some detection algorithms. In the pose estimation process, the image can be used as an optional information to estimate a current position of the ego-vehicle.

### GNSS driver

#### Input

Raw data from GNSS. Usually contains latitude and longitude information.

#### Output

Usually output should be in `sensor_msgs::NavSatFix`. This contains satellite fix status information compared to `geometry_msgs::PoseWithCovariance`, which is the final output from Sensing stack.

### IMU driver

#### Input

Raw data from IMU.

#### Output

Minimum requirement of IMU driver is to output `sensor_msgs::Imu` with measured linear acceleration and angular velocity values. Unless orientation is reported directly from the hardware (e.g. by using magnetometer), an IMU driver should not output orientation values in `sensor_msgs::Imu`. It is very common to estimate orientation from reported linear acceleration and angular velocity when using IMU sensors, but they must be done in preprocessor module rather than in a driver component.

**rationale**: Estimating orientation in driver confuses developers if the orientation error comes from hardware or from the driver.

## Preprocessors

Preprocessors are responsible for manipulating ROS message data to be more "useful" for following Autonomous Driving stacks. Actual implentation depends on how sensor data is used in other stacks. This may include:

- conversion of data format
- removing unnecessary information
- complementing necessary information
- removing noise
- imporving accuracies

Note that output of preprocessors must follow the final output ROS message type of Sensing stack.

### Pointcloud Preprocessor

PointCloud is used to capture accurate shape of surrounding environments. Therefore, some of the following functions might be appropriate:

- Self cropping: Removal of detected points from ego vehicle <br>
**rationale**: points may be detected as obstacle near the vehicle
- Distortion correction: Compensation of ego vehicle's movement during 1 scan <br>
**rationale**: This may cause inaccuracy in reported shape/position relative to the sensor origin.
- Outlier filter <br>
**rationale**: Most LiDAR data contains random noise due to hardware constraints. Detected points from flying insects or rain drops are also usually considered as noise.
- Concat filter: Combine points from multiple LiDAR outputs
- Ground filter: Removing grounds from pointcloud
- Multiplexer: Selecting pointclouds from LiDAR that is specific for certain use case

The details of the preprocess node's implementation are described in each page.

#### Input

The input is ROS message from the LiDAR driver. There may be multiple inputs if the vehicle has multiple LiDARs.

#### Output

PointCloud preprocessor may output multiple topics in sensor_msgs::PointCloud2 depending on the use case. Some examples may be:

- Concatenated pointcloud: Pointcloud from all available LiDARs may have less blind spots, enabling perception stack to detect more obstacles. It may also contain more features to be used for map matching localization
- Pointcloud without ground points: ground is usually out of interest when detecting obstacles, which helps perception.

### Camera Preprocessor

Camera preprocessor may include following functions:

- Rectification
- Resizing

#### Input

The input is `sensor_msgs::Image`, and `sensor_msgs::CameraInfo`.

#### Output

Camera preprocessor may output multiple topics in `sensor_msgs::Image` depending on the use case.
Some examples may be:

- rectified image: It is possible to rectify image using `sensor_msgs::CameraInfo` so that camera can be treated as pinhole camera model, which is useful for projecting 3D information into 2D image( or vice versa). This enables fusion of sensor data in Perception stack to improve perception result.
- resized image: Smaller images might be useful to fasten computation time.

Camera preprocessor must relay `sensor_msgs::CameraInfo` from driver node without modifying any values as all parameters should be constant.

### GNSS Preprocessor

GNSS preprocessor must do following operations:

- conversion of (latitude, longitude, altitude) to (x,y,z) in map coordinate

GNSS preprocessor may do following operations as options:

- Deriving orientation using mutiple GNSS inputs
- Filter out unreliable data

#### Input

The inputs come from GNSS drivers as `sensor_msgs::NavSatFix` message.

#### Output

The output should be `geometry_msgs::PoseWithCovariance` message and is assumed to be used for "pose estimater" in Localization stack. Each fields in the message should be calculated as following:

- Pose: This must be projected into map frame from latitude and longitude information
- Orientation: This should be derived from calculating changes in position over time or byusing mutiple GNSS sensors on vehicle.
- Covariance: Covariance should reflect reliability of GNSS output. It may be relaying covariance from the input or reflect satellite fix status.

Unreliable data can also be filtered out from the output if there is a danger of failing Localization stack.

### IMU Conversion

#### Input

`sensor_msgs::Imu` topic from IMU drivers.

#### Output

The output of IMU preprocessor can be either relayed or modified from the input. Common preprocessing of imu data include:

- bias estimation
- orientation estimation from angular_velocity and acceleration output

The need of above output depends on hardware specification of IMU, and requirements from Localization algorithm.

# References

TBU
