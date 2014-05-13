#!/usr/bin/env ruby
# encoding: utf-8

# File: macro.rb
# Created: 08/03/12
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  module Recipes
    # Macro for recipes
    class Macro
      attr_reader :actions

      # @param actions [Array] actions of the macro
      def initialize(actions = [])
        @actions = actions
      end

      # add the method call
      # @param action [Array] method call do add
      def <<(action)
        @actions << action
      end

      # run the macro methods on given  the object
      # @param object [Object] objected to be acted upon
      def act(object)
        @actions.reduce(object) do |result, action|
          # TODO: (for evolution)
          #  J2R.logger.info("playing " + action.join(','))
          result.send(*action)
        end
      end

      # clean the actions list
      def clean
        @actions = []
      end
    end
  end
end
