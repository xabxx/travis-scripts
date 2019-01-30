#!/bin/bash

docker pull ros:"$ROS_DISTRO"-ros-core
docker run -v "$PWD/shared:/shared" -e ROS_DISTRO="$ROS_DISTRO" --name "$ROS_DISTRO"-container -dit ros:"$ROS_DISTRO"-ros-core /bin/bash
docker exec "$ROS_DISTRO"-container /bin/bash -c 'mkdir -p /"$ROS_DISTRO"_ws/src'
docker exec "$ROS_DISTRO"-container /bin/bash -c 'apt update && apt install -y python3 python3-pip libgtest-dev cmake && rosdep update'
docker exec "$ROS_DISTRO"-container /bin/bash -c 'cd /usr/src/gtest && cmake CMakeLists.txt && make && cp *.a /usr/lib'
docker exec "$ROS_DISTRO"-container /bin/bash -c 'apt update && apt install -y python3-colcon-common-extensions && pip3 install -U setuptools'
docker cp $TRAVIS_BUILD_DIR "$ROS_DISTRO"-container:/"$ROS_DISTRO"_ws/src/
docker exec "$ROS_DISTRO"-container /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash && cd /"$ROS_DISTRO"_ws/ && rosdep install --from-paths src --ignore-src --rosdistro $ROS_DISTRO -r -y'
docker exec "$ROS_DISTRO"-container /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash && cd /"$ROS_DISTRO"_ws/ && colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_FLAGS="-fprofile-arcs -ftest-coverage" -DCMAKE_C_FLAGS="-fprofile-arcs -ftest-coverage"'
if [[ -z "${PACKAGE_NAME}" ]]; then
  docker exec "$ROS_DISTRO"-container /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash && cd /"$ROS_DISTRO"_ws/ && colcon build --packages-select $PACKAGE_NAME --cmake-target tests'
fi
docker exec "$ROS_DISTRO"-container /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash && cd /"$ROS_DISTRO"_ws/ && source ./install/setup.bash && colcon test'
docker exec "$ROS_DISTRO"-container /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash && cd /"$ROS_DISTRO"_ws/ && source ./install/setup.bash && colcon test-result --all'
