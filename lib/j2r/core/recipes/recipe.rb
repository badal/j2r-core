#!/usr/bin/env ruby
# encoding: utf-8

# File: recipe.rb
# Created: 23/05/12
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  # module of report creation methods
  module Recipes
    # Jacinthe recipes
    class Recipe
      class << self
        private :new
      end

      # @param name [String] raw filename of yaml file
      # @return [Pathname] full path
      def self.recipe_file(name)
        File.expand_path("#{name}.yaml", User.recipes)
      end

      ## initialization methods

      HASH_KEYS = [:db_table, :filters, :sorts, :columns, :extra_fields, :exporting, :operations]

      attr_accessor :filters, :columns, :sorts, :exporting, :operations, :internal_table
      attr_reader :db_table, :extra_fields
      attr_accessor :filename # for reporter usage

      # @return [Recipe] recipe with temporary empty table
      def self.empty
        Jaccess.create_empty_table
        from_hash(db_table: :vide)
      end

      # @return [Bool] whether recipe is empty
      def empty?
        @db_table == :vide
      end

      # @return [Recipe] a new instance
      def initialize
        @db_table = nil
        init_parameters
        @runner = Runner.new(self)
      end

      # keep the recipe object but clear it with the new table
      # @param [Symbol] table database table
      def clear_with_new_table(table)
        @db_table = table
        init_parameters
        @filename = nil
      end

      # load initial values of parameters
      def init_parameters
        @filters = []
        @sorts = {}
        @columns = {}
        @extra_fields = []
        @exporting = {}
        @operations = []
        @macro = Macro.new
      end

      ## input and output methods

      # @return [JSON] description for logging
      def info
        [@db_table, @filters, @sorts, @columns, @extra_fields, @operations, @macro.actions].to_json
      end

      # @return [Hash] hash form of recipe
      def to_hash
        {}.tap do |hsh|
          HASH_KEYS.each do |sym|
            hsh[sym] = instance_variable_get("@#{sym}".to_sym)
          end
          hsh[:actions] = @macro.actions
        end
      end

      # keep the recipe object but fill it with new data
      # @param [Hash] hsh hash of recipe data
      def fill_from_hash(hsh)
        hsh.each_pair do |sym, value|
          if sym == :actions
            instance_variable_set(:@macro, Macro.new(value))
          else
            instance_variable_set("@#{sym}".to_sym, value)
          end
        end
      end

      # @return [YAML] yaml output
      def to_yaml
        to_hash.to_yaml
      end

      # @param [Hash] hsh hash of recipe data
      # @return [Recipe] a new recipe with these data
      def self.from_hash(hsh)
        new.tap { |recipe| recipe.fill_from_hash(hsh) }
      end

      # @param [YAML] yaml yaml form of recipe data
      # @return [Recipe] a new recipe with these data
      def self.from_yaml(yaml)
        from_hash(Psych.load(yaml))
      end

      # @param [Path] path full path of yaml file
      # @return [Recipe] a new recipe with these data
      def self.from_yaml_path(path)
        yaml = File.read(path, encoding: 'utf-8')
        recipe = from_hash(Psych.load(yaml))
        recipe.filename = File.basename(path)
        recipe
      end

      # keep the recipe object but fill it with new data
      # @param [YAML] yaml yaml form of recipe data
      def fill_from_yaml(yaml)
        fill_from_hash(Psych.load(yaml))
      end

      # keep the recipe object but fill it with content of yaml file
      # @param [String] filename name of yaml file
      def fill_from_yaml_file(filename)
        yml = File.read(File.join(User.recipes, filename), encoding: 'utf-8')
        fill_from_yaml(yml)
        @filename = filename
      end

      ## macro methods

      # @return [Array] actions of the recipe macro
      def actions
        @macro.actions
      end

      # build the macro
      # @param [Array] acts actions for the macro
      def actions=(acts)
        @macro = Macro.new(acts)
      end

      # @param [Table] table table to be acted upon
      # @return [Table] result of macro acting on table
      def act(table)
        @macro.act(table)
      end

      # do and register the given action, and update the internal table
      # @param args [Array] args of action
      # @return [Table] table after action
      def do_and_add(*args)
        @macro << args
        # J2R.logger.info("adding macro :" + args.inspect)
        @internal_table = @internal_table.send(*args)
      end

      ## various field methods

      # @return [Table] updated internal table
      # @param [Array] fields fields to add
      def add_extra_fields(fields)
        @extra_fields += fields
        @extra_fields.uniq!
        @runner.run
      end

      # @return [Array<Symbol>s] all extended fields for teh recipe table
      def all_fields
        Jaccess::Model.possible_fields(@db_table)
      end

      # @return [Array] fields not "consumed"
      def possible_fields
        all_fields - @filters.keys - @extra_fields
      end

      # @return [Table] table for report
      def table_for_report
        @runner.table_for_report
      end

      # @param [Symbol] field field
      # @return [Table] table reduced to this field
      def table_for_field(field)
        @runner.build_table([field])
      end

      # @param [Symbol] field field
      # @return [Array] all existing values for this field
      def possible_values(field)
        table_for_field(field).all_values(field)
      rescue Sequel::DatabaseError
        []
      end

      # @param [Operation] oper operation to apply
      # @return [String] result of operation on full recipe
      def apply_operation(oper)
        table = table_for_field(oper.field)
        oper.act_on(table)
      end
    end
  end
end
