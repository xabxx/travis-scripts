#!/bin/bash

OIFS=$IFS
IFS=","

ros2_distro_names_arr=($ros2_distro_names)

for (( i=0; i<${#ros2_distro_names_arr[@]}; i++ ));
do
  docker pull ros:${ros2_distro_names_arr[$i]}-ros-core
  docker run -v "$PWD/shared:/shared" -e ROS_DISTRO=${ros2_distro_names_arr[$i]} --name ${ros2_distro_names_arr[$i]}-container -dit ros:${ros2_distro_names_arr[$i]}-ros-core /bin/bash
  docker exec ${ros2_distro_names_arr[$i]}-container /bin/bash -c 'mkdir -p /"$ROS_DISTRO"_ws/src'
  docker exec ${ros2_distro_names_arr[$i]}-container /bin/bash -c 'apt update && apt install -y python3 python3-pip libgtest-dev cmake && rosdep update'
  docker exec ${ros2_distro_names_arr[$i]}-container /bin/bash -c 'cd /usr/src/gtest && cmake CMakeLists.txt && make && cp *.a /usr/lib'
  docker exec ${ros2_distro_names_arr[$i]}-container /bin/bash -c 'apt update && apt install -y python3-colcon-common-extensions && pip3 install -U setuptools'
  docker cp $TRAVIS_BUILD_DIR ${ros2_distro_names_arr[$i]}-container:/"$ROS_DISTRO"_ws/src/
  docker exec ${ros2_distro_names_arr[$i]}-container /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash && cd /"$ROS_DISTRO"_ws/ && rosdep install --from-paths src --ignore-src --rosdistro $ROS_DISTRO -r -y'
  docker exec ${ros2_distro_names_arr[$i]}-container /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash && cd /"$ROS_DISTRO"_ws/ && colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_FLAGS="-fprofile-arcs -ftest-coverage" -DCMAKE_C_FLAGS="-fprofile-arcs -ftest-coverage"'
  if [[ -z "${PACKAGE_NAME}" ]]; then
    docker exec ${ros2_distro_names_arr[$i]}-container /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash && cd /"$ROS_DISTRO"_ws/ && colcon build --packages-select $PACKAGE_NAME --cmake-target tests
  fi
  docker exec ${ros2_distro_names_arr[$i]}-container /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash && cd /"$ROS_DISTRO"_ws/ && source ./install/setup.bash && colcon test'
  docker exec ${ros2_distro_names_arr[$i]}-container /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash && cd /"$ROS_DISTRO"_ws/ && source ./install/setup.bash && colcon test-result --all'
done

IFS=$OIFS;