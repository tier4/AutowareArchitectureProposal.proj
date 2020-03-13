Perception
=============
# Overview
Perception stack recognize surrounding of the vehicle in order to achieve safe and efficient autonomous driving.

![Perception_overview](/img/Perception_overview.svg)


# Role
Perception stack has 2 main roles.
- **Dynamic Object Recognition**
- **Traffic Light Recognition**

## Input

| Input Type  | Data Type                                 |
|-------------|-------------------------------------------|
| LiDAR       | `sensor_msgs::PointCoud2`                 |
| Camera      | `sensor_msgs::Image`                      |
| Map         | `autoware_lanelet2_msgs::MapBin`          |
| Drive Route | `autoware_planning_msgs::Route`           |

## Output

| Output Type         | Data Type                                          | Use Cases of the output         |
|---------------------|----------------------------------------------------|---------------------------------|
| Dynamic Object      | `autoware_perception_msgs::DynamicObjectArray`     | Planning                        |
| Traffic Light State | `autoware_perception_msgs::TrafficLightStateArray` | Planning                        |

# Design

This Perception stack cosists of 2 separated modules and each module can be subdevided into some components:
- Dynamic Object Recognition
	- Detection
	- Tracking
	- Prediction
- Traffic Light Recognition
	- Detection
	- Classification

![Perception_component](/img/Perception_component.svg)

## Dynamic Object Recognition

### Role
Recognize obstacles which could potentially move.
Provide detail information of obstacles required in Planning stack.

The motinvation behind recoginizing obstales comes from a requirement for balancing safety and efficiency in autonomous driving.
If emphasizing safety too much, need to consider every possible movements of obstacles. Autonomous vehicle could end up freezed.
If emphasizing efficiency too much, recognize every objects as static obstcles. A car could hit a pedestrian in an intersection because of the efficient drive to a destination.
Balanced autonomous driving is achieved by recoginizing obstacles.

### Requirement

![Perception_object_if](/img/Perception_object_if.svg)

#### Detection 
Detection component detects object from sensor data.

Detection component is responsible for clarifying following objects' property.
| Property  | Content |Data Type                                 | Parent Data Type|
|-------------|--|-------------------------------------------|----|
| type       | Class information|`uint8`                 |`autoware_perception_msgs::Semantic`|
| confidence  |Class's confidence. 0.0~1.0.| `float64`              |`autoware_perception_msgs::Semantic`|
| pose        |Position and orientation. |`geometry_msgs::Pose` |`autoware_perception_msgs::State`|
| orientation_reliable |Boolean for stable orientation or not.| `bool`           |`autoware_perception_msgs::State`|
| Shape |Shape in 3D bounding box, cylinder or polygon.|`autoware_planning_msgs::Shape`           ||

####  Tracking
Tracking component deals with time-series processing.

Tracking component is responsible for clarifying following objects' property.
 Property  | Content |Data Type                                 | Parent Data Type|
|-------------|--|-------------------------------------------|----|
| id      | Unique object id over frames|`uuid_msgs::UniqueID`                 |`autoware_perception_msgs::DynamicObject`|
| pose  |Position and orientaion.| `geometry_msgs::Pose`              |`autoware_perception_msgs::State`|
| twist        |Velocity in ROS twist format. |`geometry_msgs::Twist` |`autoware_perception_msgs::State`|
| twist_reliable |Boolean for stable twist or not.| `bool`           |`autoware_perception_msgs::State`|
| acceleration |Acceleration in ROS twist format.|`geometry_msgs::Twist`           |`autoware_perception_msgs::State`|
| acceleration_reliable |Boolean for stable acceleration or not.|`bool`           |`autoware_perception_msgs::State`|
| Shape |Shape in 3D bounding box, cylinder or polygon.|`autoware_planning_msgs::Shape`            ||
####  Prediction
Prediction component is responsible for clarifying following objects' property.
 Property  | Content |Data Type                                 | Parent Data Type|
|-------------|--|-------------------------------------------|----|
| predicted_path      | Predicted furuter paths for an object.|`autoware_perception_msgs::PredictedPath[]	`| |

Necessary information is defined in `autoware_perception_msg::DynamicObjectArray.msg` with layered msg structure.
![Perception_msg](/img/Perception_object_msg.svg)

### Input

#### LiDAR
`sensor_msgs::PointCloud2`

LiDAR input is essential input for recognizing objects. Its ability to describe 3D world is utilized in detecting obstacles surrounding of the vehicle.
#### Camera (optional)
`sensor_msgs::Image`

Camera input is used when requiring detail information of obstacles. Fine resolution in camera data can help easily detect objects detail informaiton.

#### Map
`autoware_lanelet2_msgs::MapBin`

Assuming the obstacles which follow rules in map, Perception stack can infer their informaiton.

### Output
`autoware_perception_msgs::DynamicObjectArray`

Recognized objects with predicted paths are used in situations like intersection, cross walk and lane change. Planning stack uses objects' information for avoiding objects or following a vehicle ahead. 

## Traffic light recognition
Make sense of traffic light's signal. 

### Definition
Not only classifying its color, but also understanding unique signals like arrow signals.

Need to recognize traffic light's signal in order to ensure safe autonomous driving.

### Requirement
Need to fill `lamp_states` in `autoware_perception_msg::TrafficLightState.msg`

![Perception_msg](/img/Perception_trafficlight_msg.svg)

Property  | Content |Data Type                                 | Parent Data Type|
|-------------|--|-------------------------------------------|----|
| lamp_states      | Seguence of traffic light result from the closest traffic light|`autoware_perception_msgs::LampState[]`                 |`autoware_perception_msgs::TrafficLightState`|

### Input

#### Camera 
`sensor_msgs::Image`

Mainly using camera data to make sense of traffic light's color. 

#### Map
`autoware_lanelet2_msgs::MapBin`

By using map with traffic light's location, clarify which part of image need to be paid attention.

#### Drive Route (optional)
`autoware_planning_msgs::Route`

With the route associated with traffic light, improve the accuracy of traffic light recognition.

### Output
`autoware_perception_msgs::TrafficLightStateArray`

Planning stack recives data from this module. It changes the vehicle manuever based on the result of traffic light recognition.  

# References