#!/bin/bash

apt update && apt install -y python3 python3-pip libgtest-dev cmake && rosdep update
cd /usr/src/gtest && cmake CMakeLists.txt && make && cp *.a /usr/lib
apt update && apt install -y python3-colcon-common-extensions && pip3 install -U setuptools
. /opt/ros/$ROS_DISTRO/setup.sh
cd /"$ROS_DISTRO"_ws/
rosdep install --from-paths src --ignore-src --rosdistro $ROS_DISTRO -r -y
colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_FLAGS='-fprofile-arcs -ftest-coverage' -DCMAKE_C_FLAGS='-fprofile-arcs -ftest-coverage'
if [ ! -z "${PACKAGE_NAME}" ];
then
  colcon build --packages-select $PACKAGE_NAME --cmake-target tests
fi
. ./install/setup.sh
colcon test
colcon test-result --all