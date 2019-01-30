#!/bin/bash

# ROS2 Bouncy Build
docker pull ros:bouncy-ros-core
docker run --name bouncy-container -dit ros:bouncy-ros-core /bin/bash
docker exec bouncy-container /bin/bash -c 'mkdir -p /ros2_ws/src'
docker exec bouncy-container /bin/bash -c 'apt update && apt install -y python3 python3-pip python3-colcon-common-extensions lcov python-rosdep && rosdep update'
docker exec bouncy-container /bin/bash -c 'pip3 install -U setuptools'
docker cp $TRAVIS_BUILD_DIR bouncy-container:/ros2_ws/src/
docker exec bouncy-container /bin/bash -c 'source /opt/ros/bouncy/setup.bash && cd /ros2_ws/ && rosdep install --from-paths src --ignore-src --rosdistro bouncy -r -y'
docker exec bouncy-container /bin/bash -c 'source /opt/ros/bouncy/setup.bash && cd /ros2_ws/ && colcon build --symlink-install'
docker exec bouncy-container /bin/bash -c 'source /opt/ros/bouncy/setup.bash && cd /ros2_ws/ && colcon test'
docker exec bouncy-container /bin/bash -c 'source /opt/ros/bouncy/setup.bash && cd /ros2_ws/ && colcon test-result --all'

# ROS2 Crystal Build
docker pull ros:crystal-ros-core
docker run --name crystal-container -dit ros:crystal-ros-core /bin/bash
docker exec crystal-container /bin/bash -c 'mkdir -p /ros2_ws/src'
docker exec crystal-container /bin/bash -c 'apt update && apt install -y python3 python3-pip python3-colcon-common-extensions lcov python-rosdep && rosdep update'
docker exec crystal-container /bin/bash -c 'pip3 install -U setuptools'
docker cp $TRAVIS_BUILD_DIR crystal-container:/ros2_ws/src/
docker exec crystal-container /bin/bash -c 'source /opt/ros/crystal/setup.bash && cd /ros2_ws/ && rosdep install --from-paths src --ignore-src --rosdistro crystal -r -y'
docker exec crystal-container /bin/bash -c 'source /opt/ros/crystal/setup.bash && cd /ros2_ws/ && colcon build --symlink-install'
docker exec crystal-container /bin/bash -c 'source /opt/ros/crystal/setup.bash && cd /ros2_ws/ && colcon test'
docker exec crystal-container /bin/bash -c 'source /opt/ros/crystal/setup.bash && cd /ros2_ws/ && colcon test-result --all'