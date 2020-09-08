Detection
=====

## Use Cases and Requirements
Detection in Traffic Light Recognition is required for usecases involved with traffic light:
* Passing intersection when traffic signal is green
* Stopping at intersection when traffic signal is red

For the details about related requirements, please refer to the [document for Perception stack](/design/Perception/Perception.md).

## Role

Detection module in Traffic Light Recognition finds traffic lights' region of interest(ROI) in the image. For example, one image could contain many traffic signals at intersection. However, the number of traffic signals, in which an autonomous vehicle is interested, is limited. Map information is used to point the part of an image which needs to be paid attention to.

## Input

| Input       | Data Type| Topic|
|-|-|-|
| Camera       | `sensor_msgs::Image`|/sensing/camera/*/image_raw|
|Camera info | `sensor_msgs::CameraInfo`|/sensing/camera/*/camera_info|
|Map | `autoware_lanelet2_msgs::MapBin`|/map/vector_map|
|TF | `tf2_msgs::TFMessage`|/tf|

## Output

| Output       | Data Type| Output Module |Topic|
|----|-|-|-|
|Cropped traffic light ROI information|`autoware_perception_msgs::TrafficLightRoiArray.msg`|Traffic Light Recognition: Classification|/perception/traffic_light_recognition/rois|

## Design
The Detection module is designed to modularize some patterns of detecting traffic lights' ROI.

![msg](/design/img/LightDetectionDesign.png)

Users/developers may choose either of the pipelin in the image: only use `Map Based Detection` or with following `Fine Detection` module. 
Map detection estimates ROI in the image by projecting the traffic light position encoded in HD Map. Therefore, the error of ROI depends on the hardware configuration and localization erros which are used to calculate relative position to traffic light in HD Map. Fine Detection will provide more accurate ROI only from the image features (usually by DNN) for better performance in classification phase.

**Rationale:** We cannot only use Fine Detection module. Since multiple traffic lights might be seen within single image, AD stack must now which traffic light result is relevant to current driving lane, and that can be only retrieved from HD Map at current moment.   
