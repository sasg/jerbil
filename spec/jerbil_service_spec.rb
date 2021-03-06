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
require 'jerbil/jerbil_service/base'
require 'jerbil'
require File.expand_path(File.dirname(__FILE__) + '/../test/test_service')


describe "Test Service Class" do



  it "should start and stop OK" do
    pkey = "ABCDEF"
    jerbil_test = get_test_jerbil
    Jerbil.stub(:get_local_server).and_return(jerbil_test)
    tservice = TestService.new(pkey, :log_dir => "/home/robert/dev/projects/jerbil/log", :log_level => :debug, :exit_on_stop=>false)
    tservice.action.should == "Hello"
    tservice.stop_callback(pkey) # make sure you do not kill anything
  end


end

def get_test_jerbil
  config_file = File.expand_path(File.dirname(__FILE__) + '/../test/conf.d/jerbil.conf')
  config = Jerbil.get_config(config_file)
  return Jerbil.get_local_server(config)
end