#
# Cookbook Name:: os_setup
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.


%w{ 
	google-chrome-stable vim gcc git gitk transmission 
	libssl-dev libreadline-dev sqlite3 libsqlite3-dev
	python3 python3-dev
  }.each do |pkg|
  package pkg do
    action :install
  end
end

remote_file "/tmp/sumlime_text3.deb" do
  source "http://c758482.r82.cf2.rackcdn.com/sublime-text_build-3065_amd64.deb"
  mode 0644
  checksum "cd71f68a10f2b549788ca9b4a504aa596a3c2fff176982d819b82f5000ebc3b6"
  not_if "which subl"
  notifies :install, "dpkg_package[sublime_text3]", :immediately
end

dpkg_package "sublime_text3" do
  source "/tmp/sumlime_text3.deb"
  action :nothing
end

cookbook_file ".gitconfig" do
	path "#{node['os_setup']['home_dir']}/.gitconfig"
	action :create_if_missing
	mode "0644"
end