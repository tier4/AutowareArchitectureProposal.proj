Perception
=============
# Overview
Perception stack recognizes the surrounding of the vehicle in order to achieve safe and efficient autonomous driving.

![Perception_overview](/img/Perception_overview.svg)


# Role
Perception stack has 2 main roles.

- **Dynamic Object Recognition**
- **Traffic Light Recognition**

## Input

| Input       | Data Type                                 |
|-------------|-------------------------------------------|
| LiDAR       | `sensor_msgs::PointCoud2`                 |
| Camera      | `sensor_msgs::Image`                      |
| Map         | `autoware_lanelet2_msgs::MapBin`          |
| Drive Route | `autoware_planning_msgs::Route`           |

## Output

| Output              | Data Type                                          | Use Cases of the output         |
|---------------------|----------------------------------------------------|---------------------------------|
| Dynamic Object      | `autoware_perception_msgs::DynamicObjectArray`     | Planning                        |
| Traffic Light State | `autoware_perception_msgs::TrafficLightStateArray` | Planning                        |

# Design

This Perception stack consists of 2 separated modules and each module can be subdivided into following components:

- Dynamic Object Recognition
	- Detection
	- Tracking
	- Prediction
- Traffic Light Recognition
	- Detection
	- Classification

![Perception_component](/img/Perception_component.svg)

**Key points of the structure**

- Interfaces are clearly separated at the current algorithm level.
- Enable complex autonomous driving use cases by including information like objects' future movement.
- Depends on technology development in the future, this structure might be changed (e.g. E2E).

## Dynamic Object

### Role
Recognize obstacles that could potentially move. Provide detail information for obstacles required in the Planning stack.

The motivation behind recognizing obstacles comes from a requirement for balancing safety and efficiency in autonomous driving. If emphasizing safety too much, it needs to consider every possible movement of obstacles. Autonomous vehicles could end up freezing. If emphasizing efficiency too much, recognize every object as static obstacles. A car could hit a pedestrian in an intersection because of the efficient drive to a destination. Balanced autonomous driving is achieved by recognizing obstacles.

### Requirement

![Perception_object_if](/img/Perception_object_if.svg)

#### Detection 

Detection component detects objects from sensor data.

Detection component is responsible for clarifying the following objects' property.

| Property  | Definition |Data Type                                 | Parent Data Type|
|-------------|--|-------------------------------------------|----|
| type       | Class information|`uint8`                 |`autoware_perception_msgs::Semantic`|
| confidence  |Class's confidence 0.0~1.0.| `float64`              |`autoware_perception_msgs::Semantic`|
| pose        |Position and orientation |`geometry_msgs::Pose` |`autoware_perception_msgs::State`|
| orientation_reliable |Boolean for stable orientation or not| `bool`           |`autoware_perception_msgs::State`|
| shape |Shape in 3D bounding box, cylinder or polygon|`autoware_perception_msgs::Shape`           |`autoware_perception_msgs::DynamicObject`|

####  Tracking

Tracking component deals with time-series processing.

Tracking component is responsible for clarifying the following objects' property.

| Property  | Definition |Data Type                                 | Parent Data Type|
|-------------|--|-------------------------------------------|----|
| id      | Unique object id over frames|`uuid_msgs::UniqueID`                 |`autoware_perception_msgs::DynamicObject`|
| twist        |Velocity in ROS twist format. |`geometry_msgs::Twist` |`autoware_perception_msgs::State`|
| twist_reliable |Boolean for stable twist or not.| `bool`           |`autoware_perception_msgs::State`|
| acceleration |Acceleration in ROS twist format.|`geometry_msgs::Twist`           |`autoware_perception_msgs::State`|
| acceleration_reliable |Boolean for stable acceleration or not.|`bool`           |`autoware_perception_msgs::State`|

####  Prediction

Prediction component is responsible for clarifying the following objects' property.

| Property  | Definition |Data Type                                 | Parent Data Type|
|-------------|--|-------------------------------------------|----|
| predicted_path      | Predicted furuter paths for an object.|`autoware_perception_msgs::PredictedPath[]	`|`autoware_perception_msgs::State` |

Necessary information is defined in `autoware_perception_msg::DynamicObjectArray.msg` with layered msg structure.

![Perception_msg](/img/Perception_object_msg.svg)

### Input

#### LiDAR

`sensor_msgs::PointCloud2`

LiDAR input is an essential input for recognizing objects. Its ability to describe the 3D world is utilized in detecting obstacles surrounding the vehicle.

#### Camera (optional)

`sensor_msgs::Image`

Camera input is used to obtain details about obstacles. Fine resolution camera enables to detect objects at far distance with high accuracy.

#### Map

`autoware_lanelet2_msgs::MapBin`

Assuming the obstacles which follow rules in a map, Perception stack can infer objects' property such as orientation or future movements by using map information.

### Output

`autoware_perception_msgs::DynamicObjectArray`

Recognized objects with predicted paths are used in situations like intersection, crosswalk and lane change. Planning stack uses objects' information for avoiding objects or following a vehicle ahead.

## Traffic light recognition

Make sense of traffic light's signal. 

### Definition

Not only classifying its color but also understanding unique signals like arrow signals.

It needs to recognize traffic light signals in order to ensure safe autonomous driving.

### Requirement

Need to fill `lamp_states` in `autoware_traffic_light_msg::TrafficLightState.msg`

![Perception_msg](/img/Perception_trafficlight_msg.svg)

Property  | Definition |Data Type                                 | Parent Data Type|
|-------------|--|-------------------------------------------|----|
| lamp_states      | Seguence of traffic light result from the closest traffic light|`autoware_perception_msgs::LampState[]`                 |`autoware_perception_msgs::TrafficLightState`|

### Input

#### Camera 

`sensor_msgs::Image`

Mainly using camera data to make sense of traffic light's color.

#### Map

`autoware_lanelet2_msgs::MapBin`

By using a map with traffic light's location, clarify which part of an image needs to be paid attention.

#### Drive Route (optional)

`autoware_planning_msgs::Route`

With the route associated with the traffic light, improve the accuracy of traffic light recognition.

### Output

`autoware_perception_msgs::TrafficLightStateArray`

Planning stack receives data from this module. It changes the vehicle maneuver based on the result of traffic light recognition.

# References

TBU
