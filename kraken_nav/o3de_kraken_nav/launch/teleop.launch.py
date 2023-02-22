#
# Copyright (c) Contributors to the Open 3D Engine Project.
# For complete copyright and license terms please see the LICENSE at the root of this distribution.
#
# SPDX-License-Identifier: Apache-2.0 OR MIT
#
#

from launch import LaunchDescription
from launch_ros.actions import Node
from launch.substitutions import LaunchConfiguration
from launch.actions import DeclareLaunchArgument


def generate_launch_description():
    namespace = LaunchConfiguration('namespace')
    declare_namespace_cmd = DeclareLaunchArgument(
        'namespace',
        default_value='',
    )
    return LaunchDescription([
        declare_namespace_cmd,
        Node(
            package='teleop_twist_joy',
            executable='teleop_node',
            name='joy_to_cmd',
            namespace=namespace
        ),
        Node(
            package='joy',
            namespace='',
            executable='joy_node',
            name='joy_node'
        ),
    ])
