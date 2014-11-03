#!/usr/bin/env ruby
# encoding: utf-8

# File: user.rb
# Created: 27/03/12
#
# (c) Michel Demazure <michel@demazure.com>

require 'singleton'

module JacintheReports
  # null logger
  class NullLogger
    # null
    def info(*)
    end
    # null
    def debug(*)
    end
    # null
    def error(*)
    end
  end

  # @return [Logger] Logger instance
  # @param [String] level debug level
  def self.user_logger(level)
    return NullLogger.new unless level
    log_file = File.expand_path('jacinthe.log', User.logs)
    logger = Logger.new(log_file, 'monthly')
    if level == 'debug'
      logger.level = Logger::DEBUG
    else
      logger.level = Logger::INFO
    end
    logger
  end

  # runs the given block in the user Jaccess environment
  # @param usr [User] user
  def self.for_user(usr = User.instance)
    params = usr.config
    @logger = user_logger(params['level'])
    jaccess(params['mode'])
    yield
  rescue StandardError => err
    log_error(err)
    process_error(err, params['error'])
  end

  # runs the given block without connection
  # @param usr [User] user
  def self.for_user_offline(usr = User.instance)
    params = usr.config
    @logger = user_logger(params['level'])
    yield
  rescue StandardError => err
    log_error(err)
    process_error(err, params['error'])
  end

  # @return [Logger] the logger
  class << self
    attr_reader :logger
  end

  # logs the error in the user log
  # @param err [Exception] error
  def self.log_error(err)
    @logger.info('FAIL') { err.to_s }
    @logger.debug('FAIL') { "#{err.inspect}\n" + err.backtrace.join("\n  ") }
  end

  # process the error according to the user config
  # @param [Error] err error to manage
  # @param [String] parameter value of user config 'raise'
  def self.process_error(err, parameter)
    return unless parameter
    fail(err) if parameter == 'raise'
    Dir.chdir(User.logs)
    prog = Dir[parameter + '.*'].first
    if prog
      File.write("#{User.logs}/error_report",
                 "#{err.inspect}\n" + err.backtrace.join("\n"),
                 encoding: 'utf-8')
      system(prog)
    end
  end

  # parameterizing methods for the given user
  class User
    include Singleton

    # logged user
    def self.logged_user
      ENV['USER']
    end

    attr_reader :name

    def initialize
      @name = User.logged_user
    end

    # @return [String] the user name
    def self.name
      instance.name
    end

    # @return [Path] user Jacinthe directory
    def directory
      @directory ||=
          case
          when J2R.win?
            "C:/Users/#{@name}/Jacinthe"
          when J2R.darwin?
            "/Users/#{@name}/Jacinthe/JacintheReports"
          when J2R.linux?
            "/home/#{@name}/Jacinthe"
          else
            fail J2R::Error::SystemError, 'System not supported'
          end
    end

    # @return [Hash] the user config
    def config
      J2R.load_config(File.expand_path('config.ini', directory))
    end

    # @return [Path] the user 'maquettes' directory
    def self.recipes
      File.expand_path('maquettes', instance.directory)
    end

    # @return [Path] the user 'sorties' directory
    def self.sorties
      File.expand_path('sorties', instance.directory)
    end

    # @return [Path] the user 'lists' directory
    def self.lists
      File.expand_path('listes', instance.directory)
    end

    # @return [Path] the user 'templates' directory
    def self.templates
      File.expand_path('templates', instance.directory)
    end

    # @return [Path] the user 'logs' directory
    def self.logs
      File.expand_path('logs', instance.directory)
    end
  end
end
