#
# Cookbook Name:: graphiti
# Attributes:: default
#
# Copyright 2013, David Whittington
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['graphiti']['user'] = "graphiti"
default['graphiti']['ruby_version'] = "1.9.3-p374"
default['graphiti']['dir'] = "/opt/graphiti"
default['graphiti']['openid'] = false
default['graphiti']['unauthenticated_networks'] = [ '127.0.0.1' ]
default['graphiti']['server_name'] = "graphiti.#{node['domain']}"
default['graphiti']['graphiti_base_url'] = "http://graphiti.#{node['domain']}"
default['graphiti']['graphite_base_url'] = "http://graphite.#{node['domain']}"
default['graphiti']['redis_url'] = "localhost:6379:0/graphiti"
