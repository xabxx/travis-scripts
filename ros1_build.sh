#!/bin/bash

OIFS=$IFS
IFS=","

ros1_distro_names_arr=($ros1_distro_names)

for (( i=0; i<${#ros1_distro_names_arr[@]}; i++ ));
do
  docker pull ros:${ros1_distro_names_arr[$i]}-ros-core
  docker run -v "$PWD/shared:/shared" -e ROS_DISTRO=${ros1_distro_names_arr[$i]} --name ${ros1_distro_names_arr[$i]}-container -dit ros:${ros1_distro_names_arr[$i]}-ros-core /bin/bash
  docker exec ${ros1_distro_names_arr[$i]}-container /bin/bash -c 'mkdir -p /"$ROS_DISTRO"_ws/src'
  docker exec ${ros1_distro_names_arr[$i]}-container /bin/bash -c 'apt update && apt install -y lcov python3-pip libgtest-dev cmake && rosdep update'
  docker exec ${ros1_distro_names_arr[$i]}-container /bin/bash -c 'cd /usr/src/gtest && cmake CMakeLists.txt && make && cp *.a /usr/lib'
  docker exec ${ros1_distro_names_arr[$i]}-container /bin/bash -c 'apt update && apt install -y python3-colcon-common-extensions && pip3 install -U setuptools'
  docker cp $TRAVIS_BUILD_DIR ${ros1_distro_names_arr[$i]}-container:/"$ROS_DISTRO"_ws/src/
  docker exec ${ros1_distro_names_arr[$i]}-container /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash && cd /"$ROS_DISTRO"_ws/ && rosdep install --from-paths src --ignore-src --rosdistro $ROS_DISTRO -r -y'
  docker exec ${ros1_distro_names_arr[$i]}-container /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash && cd /"$ROS_DISTRO"_ws/ && colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_FLAGS="-fprofile-arcs -ftest-coverage" -DCMAKE_C_FLAGS="-fprofile-arcs -ftest-coverage"'
  if [[ -z "${PACKAGE_NAME}" ]]; then
    docker exec ${ros1_distro_names_arr[$i]}-container /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash && cd /"$ROS_DISTRO"_ws/ && colcon build --packages-select $PACKAGE_NAME --cmake-target tests'
  fi
  docker exec ${ros1_distro_names_arr[$i]}-container /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash && cd /"$ROS_DISTRO"_ws/ && source ./install/setup.bash && colcon test'
  docker exec ${ros1_distro_names_arr[$i]}-container /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash && cd /"$ROS_DISTRO"_ws/ && source ./install/setup.bash && colcon test-result --all'
  docker exec ${ros1_distro_names_arr[$i]}-container /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash && cd /"$ROS_DISTRO"_ws/ && source ./install/setup.bash && lcov --capture --directory . --output-file coverage.info'
  docker exec ${ros1_distro_names_arr[$i]}-container /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash && cd /"$ROS_DISTRO"_ws/ && lcov --remove coverage.info '/usr/*' --output-file coverage.info'
  docker exec ${ros1_distro_names_arr[$i]}-container /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash && cd /"$ROS_DISTRO"_ws/ && lcov --list coverage.info'
  docker exec ${ros1_distro_names_arr[$i]}-container /bin/bash -c 'cd /$ROS_DISTRO/ && mv coverage.info /shared'
done

IFS=$OIFS;
