Planning
=============

# Overview 

Planning stack acts as the “brain” of autonomous driving. It uses all the results from Localization, Perception, and Map stacks to decide its maneuver and gives final trajectory to Control stack. 

## Role

These are high-level roles of Planning stack:

- Calculates route that navigates to desired goal
- Plans maneuver to follow the route (e.g. when to lane change, when to turn at intersection)
- Make sure that vehicle does not collide with obstacles, including pedestrians and other vehicles)
- Make sure that the vehicle follows traffic rules during the navigation. This includes following traffic light, stopping at stoplines, stopping at crosswalks, etc. 
- Plan sequences of trajectories that is feasible for the vehicle. (e.g. no sharp turns that is kinematically impossible)

## Input

The input messages to Planning stack:

| Input   | Data Type  | Explanation                             |
|---------|------------|-----------------------------------------|
|Map data        | `autoware_lanelet2_msgs::LaneletMapBin` | This includes all static information about the environment, such as: <ul><li>Lane connection information used for route planning from starting position to goal position</li><li>Lane geometry to generate reference path used to calculate trajectory </li><li> All information related to traffic rules</li></ul> |
| Detected Obstacle Information | `autoware_planning_msgs::DynamicObjectsArray` | This includes information that cannot be known beforehand such as pedestrians and other vehicles. Planning stack will plan maneuvers to avoid collision with such objects. |
| Goal position | `geometry_msgs::PoseStamped` | This is the final pose that Planning stack will try to achieve. |
| TrafficLight recognition result | `autoware_traffic_light_msgs::TrafficLightStateArray` | This is the real time information about the state of each traffic light. Planning stack will extract the one that is relevant to planned path and use it to decide whether to stop at intersections. |

## Output

The table below summarizes the output from Planning stack:

| Output  | Data Type  | Explanation                             |
|---------|------------|-----------------------------------------|
| Trajectory | `autoware_planning_msgs::Trajectory` |  This is the sequence of pose that Control stack must follow. This must be smooth, and kinematically possible to follow by the Control stack. |
|  Turn Signal | `autoware_vehicle_msgs::TurnSignal` | This is the output to control turn signals of the vehicle. Planning stack will make sure that turn signal will be turned on according to planned maneuver. |

# Design

In order to achieve the role stated above, Planning stack is decomposed into the diagram below. Mission calculates the overall route to reach goal from starting position, the scenario selector chooses  which scenario module to activate depending on situation, and selected scenario module outputs trajectory message.

We have looked into different autonomous driving stacks and came to conclusion that it is technically difficult to use unified planner to handle every possible situation. (See [here](/Planning/design_rationale) for more details). Therefore, we have decided to set different planners in parallel dedicated for each use case, and let scenario selector to decide depending on situations. Currently, we have reference implementation with two scenarios, on-road planner and parking planner, but any scenarios (e.g. highway, in-emergency, etc.) can be added as needed. 

It may be controversial whether new scenario is needed or existing scenario should be enhanced when adding new feature, and we still need more investigation to clearly set the definition of “Scenario” module.

![Planning_component](/img/Planning_overview.svg)

## Mission planner

### Role

The role of mission planner is to calculate route that navigates from current vehicle pose to goal pose. The route is made of sequence of lanes that vehicle must follow in order to reach goal pose. 

This module is responsible for calculating full route to goal, and therefore only use static map information. Any dynamic obstacle information (e.g. pedestrians and vehicles) is not considered during route planning. Therefore, output route topic is only published when goal pose is given and will be latched until next goal is provided.

**rationale**: We might need to take into account of dynamic map information, such as road construction blocking some lanes, in the future. However, this feature becomes more reasonable unless we have multiple vehicle, where each vehicle updates map online and share it with other vehicles. Therefore, we only consider static map information for now.

### Input

- current pose: `/tf` (map->base_link): <br> This is current pose in map frame calculated by Localization stack.
- goal pose: geometry_msgs::PoseStamped <br> This is goal pose given from the Operator/Fleet Management Software
- map: autoware_lanelet_msgs::MapBin <br> This is binary data of map from Map stack. This should include geometry information of each lanes to match input start/goal pose to corresponding lane, and lane connection information to calculate sequence of lanes to reach goal lane.

### Output

route: `autoware_planning_msgs::Route` <br> Message type is described below. Route is made of sequence of route section that vehicle must follow in order to reach goal, where a route section is a “slice” of a road that bundles lane changeable lanes. Note that the most atomic unit of route is lane_id, which is the unique id of a lane in vector map. Therefore, route message does not contain geometric information about the lane since we did not want to have planning module’s message to have dependency on map data structure.

![Planning_component](/img/Planning_route_msg.svg)

![Planning_component](/img/Planning_route_img.svg)

## Scenario selector

### Role

The role of scenario selector is to select appropriate scenario planner depending on situation. For example, if current pose is within road, then scenario selector should choose on-road planner, and if vehicle is within parking lot, then scenario selector should choose parking scenario.

### Input

- map: `autoware_lanelet_msgs::MapBin`
- vehicle pose: `/tf` (map->base_link)
- route: `autoware_planning_msgs::Route` <br> Scenario planner uses above three topics to decide which scenario to use. In general it should decide scenarios based on where in the map vehicle is located(map+vehicle pose) and where it is trying to go(route).
- trajectory: `autoware_planning_msgs::Trajectory` <br> Scenario planner gets the output from all the scenarios and passes the trajectory from selected scenario down to following stacks. This must be done within scenario_selector module in order to sync with the timing of scenario changing.

### Output

- scenario: `autoware_planning_msgs::Scenario` <br> This contains current available scenario and selected scenario. Each Scenario modules read this topic and chooses to plan trajectory
- Trajectory: `autoware_planning_msgs::Trajectory` <br> This is the final trajectory of Planning stack, which is the trajectory from selected Scenario module.  

## Scenarios 

### Role

The role of Scenario module is to calculate trajectory message from route message. It should only plan when the module is selected by the scenario selector module. This is where all behavior planning is done.

### Input

- Route: `autoware_planning_msgs::Route` <br> This includes the final goal pose and which lanes are available for trajectory planning.
- Map: `autoware_lanelet_msgs::MapBin` <br> This provides all static information about the environment, including lane connection, lane geometry, and traffic rules. Scenario module should plan trajectory such that vehicle follows all traffic rules specified in map.
- Dynamic Objects: `autoware_perception_msgs::DynamicObjectArray` <br> This provides all obstacle information calculated from sensors. Scenario module should calculate trajectory such that vehicle does not collide with other objects. This can be either done by planning velocity so that it stops before hitting obstacle, or by calculate path so that vehicle avoids the obstacle.
- Scenario: `autoware_planning_msgs::Scenario` <br> This is the message from scenario selector. Scenario modules only run when the module is selected by this topic.

### Output

- Trajectory: `autoware_planning_msgs::Trajectory` <br> This contains trajectory that Control must follow. The shape and velocity of the trajectory must satisfy all the use cases for the scenario module.
- Turn Signal: `autoware_vehicle_msgs::TurnSignal` <br> Turn signal command should also be published because Scenario module is only aware of the traffic rules and operating maneuvers in the whole Autoware stack.

# References

TBU
