# Autoware (Architecture Proposal)

![autoware](https://user-images.githubusercontent.com/8327598/69472442-cca50b00-0ded-11ea-9da0-9e2302aa1061.png)

A meta-repository for the new Autoware architecture feasibility study created by Tier IV. For more details about the architecture itself, please read this [overview](/design/Overview.md).

> **WARNING**: All source code relating to this meta-repository is intended solely to demonstrate a potential new architecture for Autoware, and should not be used to autonomously drive a real car!
>
> **NOTE**: Some, but not all of the features within the [AutowareArchitectureProposal.iv repository](https://github.com/tier4/AutowareArchitectureProposal.iv) are planned to be merged into [Autoware.Auto](https://gitlab.com/autowarefoundation/autoware.auto/AutowareAuto) (the reason being that Autoware.Auto has its own scope and ODD which it needs to achieve, and so not all the features in this architecture proposal will be required).

# Installation Guide

## Minimum Requirements

### Hardware

- x86 CPU (8 cores)
- 16GB RAM
- [Optional] Nvidia GPU (4GB RAM)
  - Although not required to run basic functionality, a GPU is mandatory in order to run the following components:
    - lidar_apollo_instance_segmentation
    - traffic_light_ssd_fine_detector
    - cnn_classifier

> Performance will be improved with more cores, RAM and a higher-spec graphics card.

### Software

- Ubuntu 18.04
- Nvidia driver

## Review licenses

The following software will be installed during the installation process, so please confirm their licenses first before proceeding.

- [CUDA 10.2](https://docs.nvidia.com/cuda/eula/index.html)
- [cuDNN 7](https://docs.nvidia.com/deeplearning/sdk/cudnn-sla/index.html)
- [osqp](https://github.com/oxfordcontrol/osqp/blob/master/LICENSE)
- [ROS Melodic](https://github.com/ros/ros/blob/noetic-devel/LICENSE)
- [TensorRT 7](https://docs.nvidia.com/deeplearning/sdk/tensorrt-sla/index.html)

## Installation steps

> If the CUDA or TensorRT frameworks have already been installed, we strongly recommend uninstalling them first.

1. Set up the Autoware repository

```sh
sudo apt install -y python3-vcstool
mkdir -p ~/workspace
cd ~/workspace
git clone git@github.com:tier4/AutowareArchitectureProposal.proj.git
cd AutowareArchitectureProposal.proj
mkdir -p src
vcs import src < autoware.proj.repos
```

2. Run the setup script to install CUDA, cuDNN 7, osqp, ROS and TensorRT 7, entering 'y' when prompted (this step will take around 45 minutes)

```sh
./setup_ubuntu18.04.sh
```

> ROS installation alone takes around 20 minutes and may fail during this step. In that event, please follow [steps 1.2 to 1.4 of the ROS Melodic installation guide](http://wiki.ros.org/melodic/Installation/Ubuntu) and then re-run the script in step 2 above.

3. Build the source code (this will take around 15 minutes)

```sh
source ~/.bashrc
colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release --catkin-skip-building-tests
```

> Several modules will report stderror output, but these are just warnings and can be safely ignored.

## Sensor hardware configuration

Prepare launch and vehicle description files according to the sensor configuration of your hardware.  
The following files are provided as samples:

- [sensing.launch](https://github.com/tier4/autoware_launcher.universe/blob/master/sensing_launch/launch/sensing.launch)
- [lexus_description](https://github.com/tier4/lexus_description.iv.universe)

# Running Autoware

## Quick Start

### Rosbag simulation

1. [Download the sample pointcloud and vector maps](https://drive.google.com/open?id=1ovrJcFS5CZ2H51D8xVWNtEvj_oiXW-zk), unpack the zip archive and copy the two map files to the same folder.
2. [Download the sample rosbag](https://drive.google.com/open?id=1BFcNjIBUVKwupPByATYczv2X4qZtdAeD).
3. Open a terminal and launch Autoware

```sh
cd ~/workspace/AutowareArchitectureProposal
source install/setup.bash
roslaunch autoware_launch logging_simulator.launch map_path:=/path/to/map_folder vehicle_model:=lexus sensor_model:=aip_xx1 rosbag:=true
```

4. Open a second terminal and play the sample rosbag file

```sh
cd ~/workspace/AutowareArchitectureProposal
source install/setup.bash
rosbag play --clock -r 0.2 /path/to/sample.bag
```

5. Focus the view on the ego vehicle by changing the `Target Frame` in the RViz Views panel from `viewer` to `base_link`.

#### Note

- Sample map and rosbag: © 2020 Tier IV, Inc.
  - Due to privacy concerns, the rosbag does not contain image data, and so traffic light recognition functionality cannot be tested with this sample rosbag. As a further consequence, object detection accuracy is decreased.

### Planning Simulator

1. [Download the sample pointcloud and vector maps](https://drive.google.com/open?id=197kgRfSomZzaSbRrjWTx614le2qN-oxx), unpack the zip archive and copy the two map files to the same folder.
2. Open a terminal and launch Autoware

```sh
cd ~/workspace/AutowareArchitectureProposal
source install/setup.bash
roslaunch autoware_launch planning_simulator.launch map_path:=/path/to/map_folder vehicle_model:=lexus sensor_model:=aip_xx1
```

3. Set an initial pose for the ego vehicle
   - a) Click the `2D Pose estimate` button in the toolbar, or hit the `P` key
   - b) In the 3D View pane, click and hold the left-mouse button, and then drag to set the direction for the initial pose.
4. Set a goal pose for the ego vehicle
   - a) Click the `2D Nav Goal` button in the toolbar, or hit the `G` key
   - b) In the 3D View pane, click and hold the left-mouse button, and then drag to set the direction for the goal pose.
5. Engage the ego vehicle.
   - a) Open the [autoware_web_controller](http://localhost:8085/autoware_web_controller/index.html) in a browser.
   - b) Click the `Engage` button.

#### Note

- Sample map: © 2020 Tier IV, Inc.

## Tutorials

For more information about running the AutowareArchitectureProposal code, along with more verbose instructions and screenshots, please refer to the [detailed tutorials here](./docs/tutorials/0_preparation.md). These tutorials were originally created for a workshop given at the 2020 Arm DevSummit, and have been adapted for use here.

## Running the AutowareArchitectureProposal source code with Autoware.Auto

For anyone who would like to use the features of this architecture proposal with existing [Autoware.Auto](https://gitlab.com/autowarefoundation/autoware.auto/AutowareAuto) modules right now, [ros_bridge](https://github.com/ros2/ros1_bridge) can be used.
> Until the two architectures become more aligned, message type conversions are required to enable communication between the Autoware.Auto and AutowareArchitectureProposal modules and these will need to be added manually.

- To set up Autoware.Auto, please refer to the [Autoware.Auto installation guide](https://autowarefoundation.gitlab.io/autoware.auto/AutowareAuto/installation.html).
- To set up ros_bridge, please follow the [installation instructions on the ros_bridge GitHub repository](https://github.com/ros2/ros1_bridge#prerequisites).

# References

## Autoware.IV demonstration videos

- [Scenario demo](https://youtu.be/kn2bIU_g0oY)
- [Obstacle avoidance in the same lane](https://youtu.be/s_4fBDixFJc)
- [Obstacle avoidance by lane change](https://youtu.be/SCIceXW9sqM)
- [Object recognition](https://youtu.be/uhhMIxe1zxQ)
- [Auto parking](https://youtu.be/e9R0F0ZJbWE)
- [360° FOV perception(Camera Lidar Fusion)](https://youtu.be/whzx-2RkVBA)
- [Robustness of localization](https://youtu.be/ydPxWB2jVnM)

## Credits

- [Neural Network Weight Files](./docs/Credits.md)
