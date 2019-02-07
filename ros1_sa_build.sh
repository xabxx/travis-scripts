#!/bin/bash
set -e

apt update && apt install -y python3-pip dpkg ros-$ROS_DISTRO-ros-base && rosdep update
apt update && apt install -y python3-colcon-common-extensions && pip3 install -U setuptools
. /opt/ros/$ROS_DISTRO/setup.sh
cd /"$ROS_DISTRO"_ws/"$SA_NAME"/robot_ws/
rosws update
rosdep install --from-paths src --ignore-src -r -y
colcon build