#
# Description
#
# Author:: Robert Sharp
# Copyright:: Copyright (c) 2010 Robert Sharp
# License:: Open Software Licence v3.0
#
# This software is licensed for use under the Open Software Licence v. 3.0
# The terms of this licence can be found at http://www.opensource.org/licenses/osl-3.0.php
# and in the file copyright.txt. Under the terms of this licence, all derivative works
# must themselves be licensed under the Open Software Licence v. 3.0
# 
# 

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'jerbil/server'
require 'jerbil/service'
require 'jerbil'
require 'jelly'
require 'socket'
require 'syslog'
require 'drb'

log_dir = File.expand_path(File.dirname(__FILE__) + '/../log')
key_file = File.expand_path(File.dirname(__FILE__) + '/../test/private_key_file.asc')

describe "Jerbil to Jerbil tests" do

  before(:all) do
    hostname = Socket.gethostname
    @my_key = 'DEVELOPMENT'
    DRb.start_service
    Jelly.disable_syslog
    @remote_jerbil_server = Jerbil::Server.new(hostname, 'ABCDE')
    @jerbil_server = Jerbil::Server.new(hostname, @my_key)
    @a_service = Jerbil::Service.new(:rubytest, :test)
    @b_service = Jerbil::Service.new(:rubytest, :prod)
    @remote_jerbil = @remote_jerbil_server.connect
    @remote_jerbil.register(@a_service)
    @remote_jerbil.register(@b_service)
  end

  after(:all) do
    @remote_jerbil.remove(@a_service)
    @remote_jerbil.remove(@b_service)
  end

  it "should be easy to configure a live server" do
    @remote_jerbil.services.should == 2
  end

  it "should be possible to start another server" do
    servers = [@jerbil_server, @remote_jerbil_server]
    my_options = {:log_dir=>log_dir, :log_level=>:debug, :key_file=>key_file}
    jerbil = Jerbil.new(@jerbil_server, servers, my_options)
    jerbil.verify.should be_true
    jerbil.find({}).length.should == 2
    aservice = jerbil.get({:name=>:rubytest, :env=>:test})
    aservice.should == @a_service
  end

  it "should be possible to add a service to the local server and see it remotely" do
    servers = [@jerbil_server, @remote_jerbil_server]
    my_options = {:log_dir=>log_dir, :log_level=>:debug, :key_file=>key_file}
    jerbil = Jerbil.new(@jerbil_server, servers, my_options)
    jerbil.verify.should be_true
    another_service = Jerbil::Service.new(:numbat, :dev)
    jerbil.register(another_service)
    aservice = @remote_jerbil.get({:name=>:numbat})
    aservice.should == another_service
    jerbil.remove(another_service)
    @remote_jerbil.find({}).length.should == 2
  end

end