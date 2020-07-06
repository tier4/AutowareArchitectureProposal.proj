Architecture Overview
======================

# Introduction

This architecture is a proposal by Tier IV. We thought a new Autoware architecture is required to accelerate the development of Autoware.

(Please also refer [this presentation](https://discourse.ros.org/uploads/short-url/woUU7TGLPXFCTJLtht11rJ0SqCL.pdf) shared  at AWF TSC in March 2020.)

We thought now it is difficult to improve Autoware.AI capabilities because of:
- No concrete architecture designed
- A lot of technical debt
	- Tight coupling between modules
	- Unclear responsibility of modules

The purpose of this proposal is to:
- Define a layered architecture
- Clarify the role of each module
- Simplify the interface between modules

By defining simplified interface between modules:
- Internal processing in Autoware becomes more transparent
- Joint developement of devlopers becomes easier due to less interdependency between modules
- User's can easilty replace a module with their own software component(e.g. localization) just by "wrapping" their software to adjust to Autoware inteface

Note that the initial focus of this architecture design was solely on function of driving capability, and the following features are left as future work:
* Real-time processing
* HMI
* Fail safe
* Redundant system
* State monitoring system


# Use Cases
When we designed the architecture, we have set the use case of Autoware to be last-one-mile travel. 

An example would be the following:

**Description:** Travelling from to grocery store in the same city  
**Actors:** User, Vehicle with Autoware installed (Autoware)  
**Assumption:**  
The environment is assumed to be 
- urban or suburban area that is less than 1 km^2.
- fine weather
- Accurate HD map for the environment is available

**Basic Flow:**  
1. **User:** starts a browser and access Autoware page from phone. Press "Summon", and the app sends user’s GPS location to Autoware
2. **Autoware:** plans the route to the user’s location, and show it on the user’s phone
3. **User:** confirms the route and press “Engage”
4. **Autoware:** starts driving autonomously to the requested location and pulls over to the side of the road
5. **User:** rides on to the vehicle and press "Go Home"
6. **Autoware:** Plans the route to the user’s location
7. **User:** confirms the route and press “Engage”
8. **Autoware:** Drives autonomously to user's home

# Requirements
To achieve the above use case, we set the functional requirement of the Autoware as following:
- Autoware can plan the route to the specified goal in the specified environment.
- Autoware can drive along the planned route without violation of traffic rules.
- (Nice to have) Autoware drives smooth driving for a comfortable ride with a limited jerk and acceleration.

The above requirements are broken down into detailed requirements, which are explained in each stack page.

Since Autoware is open source and is meant to be used/developed by anyone around the world, we also set some non-functional requirements for the architecture:
- Architecture is extensible for new algorithms without changing the interface
- Architecture is extensible to adapt to new traffic rules for different countries
- The role and interface of a module must be clearly defined

# High-level Architecture Design
Here is an overview of this architecture.

![Overview](/design/img/Overview2.svg)

This architecture consists of 6 stacks:
- [Sensing](Sensing/Sensing.md)
- [Localization](Localization/Localization.md)
- [Perception](Perception/Perception.md)
- [Planning](Planning/Planning.md)
- [Control](Control/Control.md)
- [Map](Map/Map.md)

The details are explained in each page. 

## Restriction on Inter-module Topics
In this new architecture proposal, we set clear rules about the use of inter-stack topics.
We clarify the final output topics from each stacks, and other stacks are only allowed to access to the final output topics from other stacks, or other internal topics within that stack.

The rule came from lessons learned from the developement of Autoware.AI. 
In Autoware.AI, the number of nodes increased so much that no one is aware of what topics are used by other nodes. As a result developers could not estimate the impact of a change in a topic to the whole system, which slowed down both development and reviews.

Therefore, in this proposal, we aimed to define minimal, yet sufficent topics between each stacks to avoid heavy inter-dependencies. For example, a node in Perception stack is only allowed to subscribed to the final output of Localization and Sensing stacks shown in the following list, and not their internal topics (e.g. `/localization/pose_estimator/pose`)

The restriction of access to topics in other stacks allows developers to: 
* easily track down issues to find which stack is malfunctioning
* make clear of their contribution. (Improvement of a stack means improvement of the accuracy of the stack's final topic)
* be aware of which topics are open to other stack and which topics are closed within stack

Of course this restriction might limit the calculation efficiency and feasibility of the whole system. However, we believe the above merits surpass these demerits as Autoware is an OSS with many developers.

The followings are the list of inter-stack topics:
- [Sensing](sensing/Sensing.md)
  - /sensing/lidar/pointcloud
  - /sensing/lidar/no_ground/pointcloud
  - /sensing/camera/image
  - /sensing/camera/camera_info
  - /sensing/gnss/pose_with_covariance
  - /sensing/imu/imu_data
- [Localization](localization/Localization.md)
  - /tf
  - /localization/twist
- [Perception](perception/Perception.md)
  - /perception/object_recognition/objects
  - /perception/traffic_light_recognition/traffic_light_states
- [Planning](planning/Planning.md)
  - /planning/trajectory
  - /vehicle/turn_signal_cmd
- [Control](control/Control.md)
  - /control/vehicle_cmd
- [Map](map/Map.md)
  - /map/pointcloud_map
  - /map/vector_map
- [Vehicle](vehicle/Vehicle.md)
  - /vehicle/status/twist
  - /vehicle/status/steering
  - /vehicle/status/shift
  - /vehicle/status/turn_signal
