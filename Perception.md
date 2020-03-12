Perception
=============
# Overview
Perception stack recognize surrounding of the vehicle in order to achieve safe and efficient autonomous driving.
# Use Cases
![Perception_overview](/img/Perception_overview.svg)
Perception stack has 2 main roles.
* Recognize obstacles.
* Recognize traffic light.
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
### Recognize obstacles
#### Definition
Recognize obstacles which could potentially move.(動く可能性のあるものを認識するといいたいが正確な表現がわからない。これだともともと動いているものは見ないのかと突っ込まれそうな気がする。)
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
### Recognize obstacles
#### Definition
Recognize obstacles which could potentially move.(動く可能性のあるものを認識するといいたいが正確な表現がわからない。これだともともと動いているものは見ないのかと突っ込まれそうな気がする。)
Provide detail information of obstacles which are required in Planning stack.
#### Purpose
The motinvation behind recoginizing obstales comes from a requirement for balancing safety and efficiency in autonomous driving.
If emphasizing safety too much, need to consider every possible movements of obstacles. Autonomous vehicle could end up freezed.
If emphasizing efficiency too much, think every objects as static obstcles. A car could hit a pedestrian in an intersection because of the efficient drive to a destination.
Balanced autonomous driving is achieved by recoginizing obstacles.
## Input use cases / Sensors
## Output use cases
出力が何/どこに使われるのかの説明
# Requirements
implementationで満たす必要があるrequirements=implementationで実装されるべき機能
# Mechanisms
上記のRequirementsを満たすために必要なbehavior, IOなど
# Design
## Components
# References