Detection
=====
# Role

Classification module recognizes traffic signal status. Unique signal types are handled in  LampState.msg definition.

## Input

| Input       | Data Type
|-|-|
| Cropped traffic light information       | `autoware_perception_msgs::TrafficLightRoiArray.msg`|
|Camera | `sensor_msgs::Image`|

## Output

| Output       | Data Type| Output Component |
|----|-|-|
|Traffic signal status|`autoware_traffic_light_msgs::TrafficLightStateArray`|Planning|

## Design
This is our sample implementation for the Classification module.
![msg](/img/LightClassificationDesign.png)


Unique signals are handled in `autoware_traffic_light_msgs::LampState`. When requiring to detect local unique signals which are not defined here, need to add them in `autoware_traffic_light_msgs::LampState`.
![msg](/img/Perception_trafficlight_msg.svg)
