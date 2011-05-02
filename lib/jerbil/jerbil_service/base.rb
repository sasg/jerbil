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
require 'jerbil/service'
require 'jerbil/errors'
require 'jerbil/config'
require 'jelly'
require 'socket'
require 'drb'

# == Jerbil Service
#
# Designed to help create ruby services easily, hiding all of the interactions with
# Jerbil itself.
#
# To create a service, create a service module (e.g. RubyTest) and within that a
# service class (e.g. RubyTest::Service) that whose parent is JerbilService::Base
# You can add a config file by copying the jerbil_service/config template and changing
# the module to your module (e.g. RubyTest::Config). Finally, use the jerbil_service/support
# module to extend your base module to include the get_config method.
#
#   module RubyTest
#
#     extend JerbilService::Support
#
#     class Service < JerbilService::Base
#
#       def initialize(pkey, options)
#
#         super(:rubytest, pkey, options)
#
#       end
#     end
#   end
#
# See also the Client, MultiClient and SuperClient classes to assist with a complete solution.
#
#
module JerbilService

  # == JerbilService::Base
  #
  # Parent class to be used for all services. Manages all interactions with Jerbil
  # and sets up a Jelly logger
  #
  class Base
    
    # create a service object
    #
    # * name - symbol for the service needs to correspond with /etc/services
    # * env - any of :dev, :test, :prod to allow multiple services at once
    # * options - hash that should include:
    #   * log_dir - writeable directory into which jelly places logs
    #   * log_level - :system, :verbose, :debug (see Jelly)
    #   * log_rotation - number of log files to keep
    #   * log_length - size of log files (in bytes)
    #   * jerbil_config - the config file for Jerbil - defaults to /etc/jermine/jerbil.conf
    #   * exit_on_stop - set to false to prevent the stop method invoking exit! For testing.
    #
    # * pkey - string containing a private key that has to be provided when calling the
    #   stop_callback
    #
    # There is a Jeckyl config class defined as a template that includes these options.
    #
    def initialize(name, pkey, options)
      @name = name.to_s.capitalize
      @env = options[:environment]
      @private_key = pkey

      # start up a logger
      @logger = Jelly.new(@name, options[:log_dir], false, options[:log_rotation], options[:log_length])
      @logger.log_level = options[:log_level]

      @exit = options[:exit_on_stop]

      begin
        @service = Jerbil::ServiceRecord.new(name, @env, :verify_callback, :stop_callback)

        # register the service
        @jerbil_server = Jerbil.get_local_server

        # now connect to it
        jerbil = @jerbil_server.connect

        # and register self
        jerbil.register(@service)

        # and start it - preventing anything nasty from coming over DRb
        $SAFE = 1
        DRb.start_service(@service.drb_address, self)

      rescue Jerbil::MissingServer
        @logger.fatal("Cannot find a local Jerbil server")
        raise
      rescue Jerbil::JerbilConfigError => err
        @logger.fatal("Error in Jerbil Config File: #{err.message}")
        raise
      rescue Jerbil::JerbilServiceError =>jerr
        @logger.fatal("Error with Jerbil Service: #{jerr.message}")
        raise
      rescue Jerbil::ServerConnectError
        @logger.fatal("Error connecting to Jerbil Server")
        raise
      rescue DRb::DRbConnError =>derr
        @logger.fatal("Error setting up DRb Server: #{derr.message}")
        raise Jerbil::ServerConnectError
      end

      @logger.system "Started service: #{@service.ident}"
    end

    # give access to Jerbil Service Record
    # WHY?
    attr_reader :service

    # return the DRb address for the service
    def drb_address
      @service.drb_address
    end

    # this is used by callers just to check that the service is running
    # if caller is unaware of the key, this will fail
    def verify_callback(key="")
      raise Jerbil::InvalidServiceKey if key != @service.key
      return true
    end

    # used to stop the service
    def stop_callback(key="")
      raise Jerbil::InvalidServiceKey if key != @private_key
      # deregister
      jerbil = @jerbil_server.connect
      jerbil.remove(@service)
      @logger.system "Stopped service: #{@service.ident}"
      @logger.close
      # and stop the DRb service, to exit gracefully
      DRb.stop_service
    end

    # wait for calls
    def wait(key='')
      raise Jerbil::InvalidServiceKey if key != @private_key
      DRb.thread.join
    end

  end
end