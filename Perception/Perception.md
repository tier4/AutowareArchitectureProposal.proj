Perception
=============
# Overview
Perception stack recognize surrounding of the vehicle in order to achieve safe and efficient autonomous driving.
# Use Cases
![Perception_overview](/img/Perception_overview.svg)
Perception stack has 2 main roles.
* Obstacles recognition.
* Traffic light recognition.
Input:
- LiDAR (`sensor_msgs::PointCoud2`)
- Camera (`sensor_msgs::Image`)
- Map (`autoware_lanelet2_msgs::MapBin`)
- Drive Route (`autoware_planning_msgs::Route`)
Output:
- Dynamic Object (`autoware_perception_msgs::DynamicObjectArray`)
  - Planning Stack
- Traffic Light State (`autoware_perception_msgs::TrafficLightStateArray`)
  - Planning Stack
## High-level use cases
### *Obstacles recognition*
#### Definition
Recognize obstacles which could potentially move.
Provide detail information of obstacles which are required in Planning stack.
#### Purpose
The motinvation behind recoginizing obstales comes from a requirement for balancing safety and efficiency in autonomous driving.
If emphasizing safety too much, need to consider every possible movements of obstacles. Autonomous vehicle could end up freezed.
If emphasizing efficiency too much, think every objects as static obstcles. A car could hit a pedestrian in an intersection because of the efficient drive to a destination.
Balanced autonomous driving is achieved by recoginizing obstacles.
## Input use cases / Sensors
### LiDAR
LiDAR input is essential input for recognizing objects. Its ability to describe 3D world is utilized in detecting obstacles surrounding of the vehicle.
### Camera: optional
Camera input is used when requiring detail information of obstacles. Fine resolution in camera data can help easily detect objects detail informaiton.
### Map
Assuming the obstacles which follow rules in map, Perception stack can infer their informaiton.
## Output use cases
### Planning
Recognized objects with predicted paths are used in situations like intersection, cross walk and lane change. Planning stack uses objects' information for avoiding objects or following a vehicle ahead. 

### *Traffic light recognition*
Make sense of traffic light's signal. 

#### Definition
Not only classifying its color, but also understanding unique signal like arrow signals.

#### Purpose
Need to recognize traffic light's signal in order to ensure safe autonomous driving.

## Input use cases / Sensors
### Camera 
Mainly using camera data to make sense of traffic light's color. 

### Map
By using map with traffic light's location, clarify which part of image need to be paid attention.

### Drive Route: optional
With the route associated with traffic light, improve the accuracy of traffic light recognition.

## Output use cases
### Planning
Planning stack recives data from this module. It changes the vehicle manuever based on the result of traffic light recognition.  

# Requirements
## Obstacles recognition
Need to fill information in `autoware_perception_msgs::DynamicObjectArray`

![Perception_msg](/img/Perception_object_msg.svg)

## Traffic light recognition
Need to fill information in `autoware_perception_msg::TrafficLightState.msg`

![Perception_msg](/img/Perception_trafficlight_msg.svg)



<!-- # Mechanismsa -->
# Design
In order to support the above stated use cases and derived requirements, a decomposition of the perception stack is proposed below.
## Components

![Perception_component](/img/Perception_component.svg)
## PointCloud Segmentation
TBU

## Image Detection
TBU

## Fusion
TBU

## Shape Estimation
TBU

## Multi Object Tracking
TBU

## Map Based Prediction
TBU

## Map based detection
TBU

## Fine detection
TBU

## classifier
TBU
# References