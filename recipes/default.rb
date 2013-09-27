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

include_recipe "build-essential"

include_recipe "apache2"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"
include_recipe "apache2::mod_auth_openid" if node['graphiti']['openid']

%w[libcurl4-gnutls-dev ruby1.9.1-full].each do |pkg|
  apt_package pkg
end

gem_package "bundler" do
  gem_binary "gem"
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

runit_service "graphiti"

git node['graphiti']['dir'] do
  user node['graphiti']['user']
  group node['graphiti']['user']
  repository "git://github.com/paperlesspost/graphiti.git"
  action :sync
  notifies :run, "bash[install_bundle]"
  notifies :restart, "service[graphiti]"
end

bash "install_bundle" do
  cwd node['graphiti']['dir']
  code "bundle check || bundle install --path=vendor --without development:test"
  action :nothing
end

template "#{node['graphiti']['dir']}/config/settings.yml" do
  owner node['graphiti']['user']
  group node['graphiti']['user']
  mode "0644"
  source "settings.yml.erb"
  notifies :restart, "service[graphiti]"
end

directory "#{node['graphiti']['dir']}/tmp" do
  owner node['graphiti']['user']
  group node['graphiti']['user']
end

directory "/var/log/graphiti" do
  owner 'root'
  group 'root'
end

cron "graphiti:metrics" do
  minute "*/1"
  path "/usr/local/bin:/usr/bin:/bin"
  command "cd #{node.graphiti.dir} && bundle exec rake graphiti:metrics"
  user "graphiti"
end

web_app "graphiti" do
  template "graphiti.conf.erb"
  docroot "#{node['graphiti']['dir']}/public"
  server_name node['graphiti']['server_name']
end
