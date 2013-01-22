#
# Cookbook Name:: graphiti
# Recipe:: default
#
# Copyright (C) 2013 David Whittington
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

if node['graphiti']['openid']
  include_recipe "apache2::mod_auth_openid"
end

include_recipe "rbenv"
include_recipe "rbenv::ruby_build"

rbenv_ruby node['graphiti']['ruby_version']

rbenv_gem "bundler" do
  ruby_version node['graphiti']['ruby_version']
end

user node['graphiti']['user'] do
  home node['graphiti']['dir']
  shell "/bin/bash"
  system true
end

directory node['graphiti']['dir'] do
  owner node['graphiti']['user']
  group node['graphiti']['user']
  mode "0755"
  recursive true
end

git node['graphiti']['dir'] do
  user node['graphiti']['user']
  group node['graphiti']['user']
  repository "git://github.com/paperlesspost/graphiti.git"
  action :sync
  notifies :run, "bash[install_bundle]"
end

file "#{node['graphiti']['dir']}/.ruby-version" do
  owner node['graphiti']['user']
  group node['graphiti']['user']
  mode "0644"
  content node['graphiti']['ruby_version']
end

bash "install_bundle" do
  cwd node['graphiti']['dir']
  code <<-EOH
  source /etc/profile
  bundle install --path=vendor
  EOH
  action :nothing
end

template "#{node['graphiti']['dir']}/config/graphiti.yml" do
  owner node['graphiti']['user']
  group node['graphiti']['user']
  mode "0644"
  source "graphiti.yml.erb"
  notifies :run, "execute[restart_graphiti]"
end

directory "#{node['graphiti']['dir']}/tmp" do
  owner node['graphiti']['user']
  group node['graphiti']['user']
end

execute "restart_graphiti" do
  command "touch #{node['graphiti']['dir']}/tmp/restart.txt"
  action :nothing
end

web_app "graphiti" do
  template "graphiti.conf.erb"
  docroot "#{node['graphiti']['dir']}/public"
  server_name node['graphiti']['server_name']
end
