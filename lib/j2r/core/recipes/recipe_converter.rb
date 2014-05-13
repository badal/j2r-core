#!/usr/bin/env ruby
# encoding: utf-8

# File: recipe_converter.rb
# Created: 09/07/12
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  module Recipes
    # to read json v1 syntax of recipes and build v2 hash
    module RecipeConverter
      # @param name [String] raw file name
      # @return [Hash] recipe hash description
      def self.hash_from_json_file(name)
        file = File.expand_path("#{name}.json", User.recipes)
        json = File.read(file, encoding: 'utf-8')
        hash_from_json(json)
      end

      # @param json [String] JSON string
      # @return [Hash] recipe hash description
      def self.hash_from_json(json)
        @hash = {}
        source, _, actions = *JSON.parse(json, symbolize_names: true, create_additions: false)
        db_table, columns, filters, parameters = *source
        build_hash_from(db_table, columns, filters, parameters, actions)
        @hash
      end

      # fill @hash
      # @param [Symbol] db_table database table
      # @param [Hash] columns hash field => name
      # @param [Hash] filters hash field => bool (old syntax)
      # @param [Array] parameters list of parameters
      # @param [Array] actions macro actions
      def self.build_hash_from(db_table, columns, filters, parameters, actions)
        @hash[:db_table] = db_table.to_sym
        @hash[:sorts] = {}
        @hash[:actions] = []
        @hash[:extra_fields] = []
        @hash[:columns] = columns
        @hash[:filters] = filters.each_pair.map do |field, value|
          val = parameters.include?(value) ? JOKER : value
          [field, val, true]
        end
        actions.each { |action| process_action(action) }
      end

      # process old macro actions
      # @param [Array] action action to be processed
      # FLOG: 30.5
      def self.process_action(action) # rubocop:disable MethodLength
        key_word = action.shift.to_sym
        col = action.shift
        field = @hash[:columns].rassoc(col).first
        case key_word
        when :select_value
          value, flag = *action
          value = SQUARE if value == 'VIDE'
          @hash[:filters] << [field, value, flag]
        when :sort_column
          @hash[:sorts][field] = true
        when :inverse_sort_column
          @hash[:sorts][field] = false
        when :delete_col
          @hash[:columns].delete(field)
        when :compare
          value_out, value_in = *action
          list = build_ids(@hash[:columns].keys - [field])
          @hash[:extra_fields] += list
          @hash[:actions] << [:compare, list, field, value_out, value_in]
        else
          puts "l'action #{key_word} #{col} #{action} n'a pas été récupérée"
        end
      end

      # @param [Array<Symbol>] list of fields
      # @return [Array<Symbol>] list of identifier fields of corresponding tables
      def self.build_ids(list)
        Jaccess::Model.model_table.keys.map do |table|
          list.map do |field|
            "#{table}_id".to_sym if Regexp.new('^' + table.to_s).match(field.to_s)
          end
        end.flatten.compact.uniq
      end
    end
  end
end
