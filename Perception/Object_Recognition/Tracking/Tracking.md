Detection
=====
# Role
Tracking in Object Recognition keeps objects' unique id over time. This time series processing leads to estimating objects' property such as their velocity and/or acceleration. Furthermore, it could estimate more accurate objects' orientation by leveraging the Detection results over time.

## Input

| Input       | Data Type
|-|-|
| Dynamic Objects       | `autoware_perception_msgs::DynamicObjectArray`|
|TF  | `tf2_msgs::TFMessage`           |

## Output

| Output       | Data Type| Output Module | TF Frame
|----|-|-|-|
|Dynamic Objects|`autoware_perception_msgs::DynamicObjectArray`|Object Recognition: Prediction| `map`|

## Design
This is our sample implementation for the Tracking module.
![msg](/img/ObjectTrackingDesign.png)


## Requirement in Output
![msg](/img/ObjectTrackingRequirement.png)
Designated objects' properties in autoware_perception_msgs::DynamicObject need to be filled in the Tracking module before passing to the Prediction module.


| Property  | Definition |Data Type                                 | Parent Data Type|
|-------------|--|-------------------------------------------|----|
| id      | Unique object id over frames|`uuid_msgs::UniqueID`                 |`autoware_perception_msgs::DynamicObject`|
| twist        |Velocity in ROS twist format. |`geometry_msgs::TwistWithCovariance` |`autoware_perception_msgs::State`|
| twist_reliable |Boolean for stable twist or not.| `bool`           |`autoware_perception_msgs::State`|
| acceleration |Acceleration in ROS accel format.|`geometry_msgs::AccelWithCovariance`           |`autoware_perception_msgs::State`|
| acceleration_reliable |Boolean for stable acceleration or not.|`bool`           |`autoware_perception_msgs::State`|
