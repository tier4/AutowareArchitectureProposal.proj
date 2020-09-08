Classification
=====
## Use Cases and Requirements
Classification in Traffic Light Recognition is required for usecases involved with traffic light:
* Passing the intersection when traffic light is green
* Stopping at the intersection when traffic signal is red

For the details about related requirements, please refer to the [document for Perception stack](/design/Perception/Perception.md).

## Role

Classification module recognizes traffic signal status. Unique signal types are handled in LampState.msg definition.

## Input

| Input| Data Type| Topic|
|-|-|-|
| Cropped traffic light information | `autoware_perception_msgs::TrafficLightRoiArray.msg`|/perception/traffic_light_recognition/rois
|Camera | `sensor_msgs::Image`|/sensing/camera/*/image_raw|

## Output

| Output| Data Type| Output Component |Topic|
|----|-|-|-|
|Traffic signal status|`autoware_traffic_light_msgs::TrafficLightStateArray`|Planning|/perception/traffic_light_recognition/traffic_light_states|

## Design
This is our sample implementation for the Classification module.
![msg](/design/img/LightClassificationDesign.png)

Unique signals are handled in `autoware_traffic_light_msgs::LampState`. When requiring to detect local unique signals which are not defined here, need to add them in `autoware_traffic_light_msgs::LampState`.

Message design is illustrated in the following image.
![msg](/design/img/PerceptionTrafficLightMsg.png)

Classificaiton module will provide one `TrafficLightState` message for each traffic light. Each `TrafficLightState` consists of on or more `LampState` msg which describes the combination of lamps that are lighting. 

For example, output of the classification result against the image below would be: 
![image](/design/img/traffic_light_example.png)

```
TrafficLightState:
  - id: 1 # HD map id of traffic light  
  - lamp_states:
    - 
      type: 1 # RED
      confidence: 1.0
    - 
      type: 5 # RIGHT GREEN ARROW
      confidence: 1.0
```