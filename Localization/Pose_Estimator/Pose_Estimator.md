Pose Estimator
==============

## Role

Pose estimator is a component to estimate ego vehicle pose in local coordinates on reference map. We basically adopt 3D NDT registration method for pose estimation algorithm. In order to realize fully automatic localization, initial pose estimation with GNSS is required. In general, iterative methods such as point cloud registration method require a good initial guess. Therefore it is preferable to utilize pose output of pose twist fusion filter as initial guess of NDT registration. Also, pose estimator should stop publishing pose when the score of NDT matching is less than threshold to avoid misleading wrong estimation.

## Input

| Input          | Data Type                                            |
|----------------|------------------------------------------------------|
| LiDAR          | `sensor_msgs::PointCoud2`                            |
| GNSS           | `geometry_msgs::PoseWithCovarianceStamped`           |
| Pointcloud Map | `sensor_msgs::PointCoud2`                            |
| Feedback from<br>Pose Twist Fusion Filter | `geometry_msgs::PoseWithCovarianceStamped` |

## Output

| Output         | Data Type                                   | Use Cases of the output         |
|----------------|---------------------------------------------|---------------------------------|
| Initial Pose   | `geometry_msgs::PoseWithCovarianceStamped`  | Pose Twist Fusion Filter        |
| Estimated Pose | `geometry_msgs/PoseStamped`                 | Pose Twist Fusion Filter        |

## Design

This is a sample design of our implementation using NDT Scan Matcher. 
![Pose_Estimator](/img/Pose_Estimator.svg)

NDT Scan Matcher has two roles as below.
- Initial pose alignment using poses generated randomly based on GNSS pose. (This is implemented as a service of ROS)
- Pose alignment using output pose from Pose Twist Fusion Filter as a initial guess.

Note that NDT scan matcher does not publish pose when matching score calculated in alignment is less than threshold value to avoid publishing wrong estimated pose to Pose Twist Fusion Filter.

Lidar sensors usually operate at 10 ~ 20 Hz and therefore NDT alignment should be executed within approximately 100 ms. In order to reduce execution time, We apply two pointcloud preprocessors to raw pointcloud from lidar sensors; Crop Measurement Range and DownSampler.
- Crop Measurement Range removes points far from ego vehicle.
- DownSampler reduces the number of points by calculating a centroid of points in each voxelized grid.

Pose initializer adds height information into initial pose obtained from GNSS by looking for minimum height point from points within 1 m. 

