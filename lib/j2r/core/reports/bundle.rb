#!/usr/bin/env ruby
# encoding: utf-8

# File: report.rb
# Created: 29/01/12
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  module Reports
    # bundle of reports for Jacinthe
    class Bundle
      # methods to be skipped
      FAKE_METHODS = [:select_value, :delete_col, :cross_table,
                      :compare, :split, :to_csv_user_file, :to_csv_file, :temp_csv]

      include CommonFormatters

      attr_accessor :title

      # @param tables [hash] subtitle => subtable
      # @param title [String]  title of bundle
      def initialize(tables, title)
        @tables = tables
        @title = title || 'Sans titre'
      end

      # quack !
      def columns
        []
      end

      # duck !
      def running_title
        @title
      end

      # quack !
      def all_values(*)
        []
      end

      # duck !
      def method_missing(method, *)
        if FAKE_METHODS.include?(method)
          self
        else
          # noinspection RubySuperCallWithoutSuperclassInspection
          super
        end
      end

      # @return [Hash] subtitle => size of subtable
      def sizes
        {}.tap do |hsh|
          @tables.each_pair { |key, table| hsh[key] = table.size }
        end
      end

      # @return [Integer] number of lines
      def size
        @tables.values.map(&:size).reduce(&:+)
      end

      # produce and save pdf formatted output
      # @param name [String]  raw name of output file
      # @return [String] full path of output file
      def to_pdf_user_file(name = default_name, title = @title)
        path = File.expand_path("#{name}.pdf", User.sorties)
        to_pdf_file(path, title)
      end

      # @param path [Pathname] path of file to build
      # @param title [String] title of bundle
      # @return [Pathname] given path
      def to_pdf_file(path, title = @title)
        require 'prawn'
        Bundle.prawn_generate(path, title, @tables)
        path
      end

      # to be done
      def txt_output
        'Non disponible'
      end

      # Output to bunch of csv files in subdirectoty
      def to_csv_usr_file
        dir = File.expand_path(default_name, User.sorties)
        Dir.mkdir(dir)
        @tables.each do |name, table|
          path = File.expand_path("#{name}.csv", dir)
          J2R.to_file(path, table.csv_output, J2R.system_csv_encoding)
        end
        "Fichiers créés dans #{dir}"
      end

      # @param title [String] title of bundle
      def html_output(title = @title)
        head = [CommonFormatters::META, '<a name = "retour"</a>', "<h2>#{title}</h2>"]
        tables = @tables.each_pair.map do |val, table|
          ["<a name = \"#{val}\"></a>", "<h4>#{val} [#{table.size_to_print}]</h4>",
           '<a href = "#retour">Retour à la liste des valeurs</a>', '<p></p>',
           table.doc_for_html]
        end
        (head + bundle_table + tables).flatten.join("\n")
      end

      # @return [String] html extract for reporter
      def html_sample
        ([CommonFormatters::META, "<h3>#{@title}</h3>"] + bundle_table).flatten.join("\n")
      end

      # @return [Array<String>] sizes table of bundle
      def bundle_table
        %w(<ul>) +
            @tables.each_pair.map do |val, table|
              "<li><a href = \"\##{val}\"> #{val} [#{table.size_to_print}]</li>\n"
            end +
            %w(</ul>)
      end

      # @param [Hash] tables list of tables : String => Table
      # @param [Path] path path of output file
      # @param [String] titre title of pdf report
      def self.prawn_generate(path, titre, tables) # rubocop:disable MethodLength
        Prawn::Document.generate(path) do
          text(titre, align: :center, size: 15)
          move_down 10
          text(tables.keys.join(', '), align: :center, size: 12)
          generate_content(tables)
        end
      end

      # @param [Hash] tables list of tables : String => Table
      # @return [String] pdf for these tables
      def self.generate_content(tables)
        tables.each_pair.with_index do |(val, tbl), indx|
          indx == 0 ? move_down(20) : start_new_page
          text("#{val} [#{tbl.size} lignes]", size: 12)
          move_down 20
          font_size 9
          table(tbl.doc_for_pdf, CommonFormatters::PRAWN_FORMAT) unless tbl.empty?
        end
      end
    end
  end
end

__END__
