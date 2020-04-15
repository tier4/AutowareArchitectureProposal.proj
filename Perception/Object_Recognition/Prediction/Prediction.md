Detection
=====
# Role
Prediction in Object Recognition estimate objects' intention. Intentions are represented as objects' future trajectories with covariance. The Planning module makes a decision and plans a future ego-motion based on the results of predicted objects.

## Input

| Input       | Data Type
|-|-|
| Dynamic Objects       | `autoware_perception_msgs::DynamicObjectArray`|
|Map|`autoware_lanelet2_msgs::MapBin`|
|TF  | `tf2_msgs::TFMessage`           |

## Output

| Output       | Data Type| Output Componenet | TF Frame
|----|-|-|-|
|Dynamic Objects|`autoware_perception_msgs::DynamicObjectArray`|Planning| `map`|

## Design
This is our sample implementation for the Tracking module.
![msg](/img/ObjectPredictionDesign.png)


## Requirement in Output
Designated objects' property in autoware_perception_msgs::DynamicObject needs to be filled in the Prediction module before passing to the Planning component.
![msg](/img/ObjectPredictionRequirement.png)


| Property  | Definition |Data Type                                 | Parent Data Type|
|-------------|--|-------------------------------------------|----|
| predicted_path      | Predicted furuter paths for an object.|`autoware_perception_msgs::PredictedPath[]	`|`autoware_perception_msgs::State` |
