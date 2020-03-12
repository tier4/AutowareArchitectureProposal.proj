Architecture overview
======================

# Introduction

This architecture is a proposal by Tier IV. We thought a new Autoware architecture is requiered to accelerate a development of Autoware.

We thought now it is difficult to improve Autoware.AI capabilities because of:
- No concrete architecture designed
- A lot of tecnical debt
	- Tight coupling between modules
	- Unclear responsibility of modules

Then, this proposed architecture is designed to follow the guideline below:
- Define a layered architecture
- Clarify the role of each module
- Simplify the interface between modules

# Use Cases

We considered some use cases during architecture design. For example:
- 360-degree sensing/perception by the camera-LiDAR fusion
- Robust Localization using multiple data sources
- Dynamic route planning based on vector maps
- Automatic parking
- Object avoidance
- Abstraction of vehicles (to support many kinds of vehicles)

So it's easier for developpers to develop functions to archieve use cases above with this architecture than Autoware.AI.

# Overview

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
