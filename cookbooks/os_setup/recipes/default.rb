#
# Cookbook Name:: os_setup
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

bash "remove ubuntu web search" do
  code "gsettings set com.canonical.Unity.Lenses remote-content-search 'none'"
  not_if "gsettings get com.canonical.Unity.Lenses remote-content-search | grep --silent none"
end

bash "disable shopping lenses" do
  code "gsettings set com.canonical.Unity.Lenses disabled-scopes \"['more_suggestions-amazon.scope', 'more_suggestions-u1ms.scope', 'more_suggestions-populartracks.scope', 'music-musicstore.scope', 'more_suggestions-ebay.scope', 'more_suggestions-ubuntushop.scope', 'more_suggestions-skimlinks.scope']\""
  not_if "gsettings get com.canonical.Unity.Lenses disabled-scopes | grep --silent more_suggestions-amazon.scope"
end

bash "disable stupid floaty scrollbars" do
  code "gsettings set com.canonical.desktop.interface scrollbar-mode normal"
  not_if "gsettings get com.canonical.desktop.interface scrollbar-mode | grep --silent normal"
end

bash "make ssh key" do
  code "ssh-keygen -t rsa -N \"\" -f #{node['os_setup']['home_dir']}/.ssh/id_rsa"
  not_if "stat #{node['os_setup']['home_dir']}/.ssh/id_rsa"
end

# install normal stuff
%w{ 
  vim gcc git gitk transmission curl
  libssl-dev libreadline-dev sqlite3 libsqlite3-dev
  python3 python3-dev python3-pip
  }.each do |pkg|
  package pkg do
    action :install
  end
end

bash "install virtualenv" do
  code "pip3 install virtualenv"
  not_if "stat /usr/local/bin/virtualenv"
end

bash "install virtualenvwrapper" do
  code "pip3 install virtualenvwrapper"
  not_if "stat /usr/local/bin/virtualenvwrapper.sh"
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

cookbook_file "Preferences.sublime-settings" do
  path "#{node['os_setup']['home_dir']}/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
  action :create
  mode 0644
end

cookbook_file ".gitconfig" do
  path "#{node['os_setup']['home_dir']}/.gitconfig"
  action :create
  mode 0644
end

# annoying dependencies for chrome
%w{ libindicator7 libappindicator1 }.each do |pkg|
  package pkg do
    action :install
  end
end

bash "check chrome install" do
  code "which google-chrome"
  returns 1
  not_if "which google-chrome"
  notifies :create, "remote_file[/tmp/google-chrome-stable_current_amd64.deb]", :immediately
  notifies :install, "dpkg_package[google-chrome]", :immediately
end

remote_file "/tmp/google-chrome-stable_current_amd64.deb" do
  action :nothing
  source "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
  mode 0644
end

dpkg_package "google-chrome" do
  action :nothing
  source "/tmp/google-chrome-stable_current_amd64.deb"
end

bash "check monaco font" do
  code "stat /usr/share/fonts/truetype/custom/Monaco_Linux.ttf"
  returns 1
  not_if "stat /usr/share/fonts/truetype/custom/Monaco_Linux.ttf"
  notifies :create, "remote_file[/tmp/install-font-ubuntu.sh]", :immediately
  notifies :run, "bash[install monaco font]", :immediately
end

remote_file "/tmp/install-font-ubuntu.sh" do
  action :nothing
  source "https://raw.github.com/cstrap/monaco-font/master/install-font-ubuntu.sh"
  mode 0755
end

bash "install monaco font" do
  action :nothing
  code "/tmp/install-font-ubuntu.sh"
end

directory "#{node['os_setup']['home_dir']}/dev" do
  owner node['os_setup']['user']
  group node['os_setup']['user']
end

directory "#{node['os_setup']['home_dir']}/dev/python3_projects" do
  owner node['os_setup']['user']
  group node['os_setup']['user']
end


ruby_block "edit .bashrc" do
  block do
    f = Chef::Util::FileEdit.new("#{node['os_setup']['home_dir']}/.bashrc")
    f.insert_line_if_no_match(/WORKON_HOME/, "export WORKON_HOME=#{node['os_setup']['home_dir']}/.virtualenvs")
    f.insert_line_if_no_match(/PROJECT_HOME/, "export PROJECT_HOME=#{node['os_setup']['home_dir']}/dev/python3_projects")
    f.insert_line_if_no_match(/virtualenvwrapper.sh/, "source /usr/local/bin/virtualenvwrapper.sh")
    f.write_file
  end
  not_if "grep --silent WORKON_HOME #{node['os_setup']['home_dir']}/.bashrc"
end


