Messages
==========

# Overview

In this section, it is descrived that 8 categories of messages in the architecture:

- autoware control messages
- autoware lanelet2 messages
- autoware perception messages
- autoware planning messages
- autoware system messages
- autoware traffic light messages
- autoware vector map messages
- autoware vehicle messages

the difinition of each message is shown in following subsection.

## autoware control messages

There are 2 types of messages related with control stack.
The difinitions are as below.

### ControlCommand.msg

`float64 steering_angle`  
`float64 steering_angle_velocity`  
`float64 velocity`  
`float64 acceleration`

### ControlCommandStamped.msg

`Header header`  
`autoware_control_msgs/ControlCommand control`

## autoware lanelet2 messages

### MapBin.msg

`Header header`  
`string format_version`  
`string map_version`  
`int8[] data`

## autoware perception messages

## autoware planning messages

## autoware system messages

## autoware traffic light messages

## autoware vector map messages

## autoware vehicle messages







