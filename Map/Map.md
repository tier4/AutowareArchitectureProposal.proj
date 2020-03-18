Map
=============

# Overview 

Map is responsible for distributing static information about the environment that autonomous vehicle might drive. Currently, this is separated into two categories:

- Geometric information about the environment (pointcloud map)
- Semantic information about roads (vector map)

## Role 

The role of map is to publish map information to other stacks.

## Input

The input to Map stack:

| Input      | Data Type | Explanation          | 
|------------|-----------|----------------------|
| PointCloud Map file | PCD format | This includes the shape of surrounding environment as collection of raster points, including grounds and buildings. It may include other additional information such as intensity and colors for visualization. |
| Vector Map file | Lanelet2 format | This should describe all semantic information about roads. This includes road connection, road geometry, and traffic rules. Supporting format may change to OpenDRIVE in the future as discussed in Map WG. |

### Output

The table below summarizes the output from Map stack:

| Output      | Data Type | Explanation          | 
|-------------|-----------|----------------------|
| PointCloud map | `sensor_msgs::PointCloud2` | This includes the shape of surrounding environment as collection of points. <br> This is assumed to be used by Localization module for map matching with LiDAR pointclouds. |
| Vector Map | `autoware_lanelet2_msgs::MapBin` | Lanelet2 map information will be dumped as serialized data, and passed down to other stacks. Then, it will be converted back to internal data structure to enable Lanelet2 library API access to each data. <br> This is assumed to be used by Localization stack for lane-based localization, Perception stack for trajectory prediction of other vehicles, and Planning to plan behavior to follow traffic rules.

# Design

Map module consist of two modules: pointcloud map loader and vector map loader. Since map data are converted into binary data array, it is meant to be converted back to internal data structure using appropriate library, for example PCL for pointcloud and Lanelet2 for vector map. The access to each data element is also assumed to be done through map library.

![Map_component](/img/Map_overview.svg)

## PointCloud Map Loader

### Role

Role of this module is to output pointcloud map in `map` frame to be used by other stacks.

### Input

- PCD File <br> This contains collection of point coordinates from reference point.
- YAML File <br> This is meant to contain the coordinate of origin of PCD file in earth frame (either in ECEF or WGS84)

### Output

- pointcloud_map: `sensor_msgs::PointCloud2` <br> This module should output environment information as pointcloud message type. The points in the message should be projected into map frame since the main user is assumed to be Localization stack.

## Lanelet2 Map Loader

### Role

Role of this module is to output road information in map frame to be used by other stacks.

### Input

- Lanelet2 Map File (OSM file) <br> This includes all lane-related information. The specification about the format is specified [here(TBU)](). 

### Output

- vector_map `autoware_lanelet_msgs::MapBin` <br> This contains serialized data of Lanelet2 map. All coordinate data contained in the map should be already projected into map frame using specified ECEF parameter. 

# References

TBU