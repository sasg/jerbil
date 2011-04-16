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
require 'jerbil/jerbil_service_class'

# Test Service for Jerbil

class BadTestService < JerbilService
  
  def initialize(options)
    super(:rubynonsense, :test, options)
  end

  def action
    @logger.debug("Someone called the action method!")
    return "Hello"
  end
  
end

