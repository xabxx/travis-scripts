#!/bin/bash
set -e

apt update && apt install -y python3-pip python3-apt dpkg ros-$ROS_DISTRO-ros-base && rosdep update
apt update && apt install -y python3-colcon-common-extensions && pip3 install -U setuptools
pip3 install --upgrade pip
pip3 install colcon-bundle colcon-ros-bundle
. /opt/ros/$ROS_DISTRO/setup.sh
cd /"$ROS_DISTRO"_ws/"$SA_NAME"/robot_ws/
rosws update
rosdep install --from-paths src --ignore-src -r -y
colcon build --build-base build --install-base install
colcon bundle --build-base build --install-base install --bundle-base bundle
cp /"$ROS_DISTRO"_ws/"$SA_NAME"/appspec.yml /shared/appspec.yml
mv /"$ROS_DISTRO"_ws/"$SA_NAME"/robot_ws/bundle/output.tar.gz /shared/output.tar.gz