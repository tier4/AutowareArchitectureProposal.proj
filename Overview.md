Architecture overview
======================

# Introduction

This architecture is a proposal by Tier IV. We thought a new Autoware architecture is requiered to accelerate a development of Autoware.

We thought now it is difficult to improve Autoware.AI capabilities because of:
- No concrete architecture designed
- A lot of tecnical debt
	- Tight coupling between modules
	- Unclear responsibility of modules

The purpose of this proposal is to:
- Define a layered architecture
- Clarify the role of each module
- Simplify the interface between modules

so that it's easier for developers to develop functions to achieve use cases above with this architecture than Autoware.AI.

# Use Cases
When we designed the architecture, we have set the use case of Autoware to be last-one-mile travel. 

An example would be the following:


**Description:** Travelling from to grocery store in the same city  
**Actors:** User, Fleet Management System(FMS), Vehicle with Autoware installed (Autoware)  
**Assumption:**  
The environment is assumed to be 
- urban or suburban area that is less than 1 km^2.
- fine weather
- Accurate HD map for the environment is available

**Basic Flow:**  
1. **User:** starts the FMS app from phone and press "Summon", and the app sends user’s GPS location to Autoware
2. **Autoware:** plans the route to the user’s location, and show it on the user’s phone
3. **User:** comfirms the route and press “Engage”
4. **Autoware:** starts driving autonomously to the requested location and pulls over to the side of the road
5. **User:** rides on to the vehicle and press "Go Home"
6. **Autoware:** Plans the route to the user’s location
7. **User:** comfirms the route and press “Engage”
8. **Autoware:** Drives autonomously to user's home

# Requirements
In order to achieve above use case, we set the functional requirement of the Autoware as following:
- Autoware can plan the route to specified goal in the specified environment.
- Autoware can drive along planned route without violation of traffic rules.
- (Nice to have) Autoware drives smooth driving for comfortable ride with limited jerk and acceleration

Above requirements are broken down into detailed requirements, which are explained in [this page](/requirements).

Since Autoware is open source and is meant to be used/developed by anyone around the world, we also set some non-functional requirements for the architecture:
- Architecture is extensible for new algorithms without changing interface
- Architecture is extensible to adopt to new traffic rules for different coutnries
- The role and interface of a module must be clearly defined

# High-level Architecture Design
Here is the overview of this architecture.

![Overview](/img/Overview_2.svg)

This architecture consists of 6 staks:
- Sensing
- Localization
- Perception
- Planning
- Control
- Map

The detail of these are explained in each stack page. Please refer the pages.
