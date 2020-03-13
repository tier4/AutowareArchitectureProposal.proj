Perception
=============
# Overview
Perception stack recognize surrounding of the vehicle in order to achieve safe and efficient autonomous driving.

![Perception_overview](/img/Perception_overview.svg)


# Role
Perception stack has 2 main roles.
- **Obstacles recognition**
- **Traffic light recognition**

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
- Dynamic object recognition
	- Detection
	- Tracking
	- Prediction
- Traffic light recognition
	- Traffic light detection
	- Traffic light classifier

![Perception_component](/img/Perception_component.svg)

## Dynamic object recognition

### Role
Recognize obstacles which could potentially move.
Provide detail information of obstacles required in Planning stack.

The motinvation behind recoginizing obstales comes from a requirement for balancing safety and efficiency in autonomous driving.
If emphasizing safety too much, need to consider every possible movements of obstacles. Autonomous vehicle could end up freezed.
If emphasizing efficiency too much, recognize every objects as static obstcles. A car could hit a pedestrian in an intersection because of the efficient drive to a destination.
Balanced autonomous driving is achieved by recoginizing obstacles.

### Requirement

![Perception_object_if](/img/Perception_object_if.svg)


Need to fill information in `autoware_perception_msgs::DynamicObjectArray`

![Perception_msg](/img/tmp.svg)

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
Not only classifying its color, but also understanding unique signal like arrow signals.

Need to recognize traffic light's signal in order to ensure safe autonomous driving.

### Requirement
Need to fill information in `autoware_perception_msg::TrafficLightState.msg`

![Perception_msg](/img/Perception_trafficlight_msg.svg)

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