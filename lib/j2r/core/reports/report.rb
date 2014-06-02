#!/usr/bin/env ruby
# encoding: utf-8

# File: report.rb
# Created: 29/01/12 for v1
# Emptied: 19/05/12 for v2
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  # designing, producing, and outputting reports
  module Reports
    # reports for Jacinthe
    class Report
      include CommonFormatters

      attr_accessor :title

      # @param table [Table] content of report
      # @param title [String]  title of report
      def initialize(table, title = nil)
        @table = table
        @title = title || 'Sans titre'
      end

      # @return [Integer] number of lines
      def size
        @table.size
      end

      # @return [String]  running titla
      def running_title
        len = size
        extra = case len
                when 0
                  'vide'
                when 1
                  'une ligne'
                else
                  "#{len} lignes"
                end
        title + " [#{extra}]"
      end

      # @param [Integer] lim size of extract
      # @return [Report] extract
      def take(lim)
        Report.new(@table.take(lim), running_title)
      end

      # produce and save pdf formatted output
      # @param name [String]  raw name of output file
      # @return [String] full path of output file
      def to_pdf_user_file(name = default_name)
        path = File.expand_path(name + '.pdf', User.sorties)
        to_pdf_file(path)
      end

      # produce and save pdf formatted output
      # @param path [String] path of file
      def to_pdf_file(path)
        require 'prawn'
        Report.prawn_generate(path, title, @table)
        path
      end

      # @return [Array<String>] console output
      def txt_output
        return [running_title] if size == 0
        [running_title] + @table.doc_for_txt
      end

      # produce and save csv formatted output
      # @param name [String]  raw name of output file
      # @return [String] full path of output file
      def to_csv_user_file(name = default_name)
        path = File.expand_path(name + '.csv', User.sorties)
        J2R.to_csv_file(path, @table.csv_output)
      end

      # produce and save csv formatted output
      # @param path [String]  full path of output file
      # @return [String] full path of output file
      def to_csv_file(path)
        J2R.to_csv_file(path, @table.csv_output)
      end

      # @return [Pathname] path of a temp file with the table csv content
      def temp_csv
        coding = J2R.system_csv_encoding
        J2R.to_temp_file('.csv', @table.csv_output, coding)
      end

      # @return [String] html formatted output
      # @param title [String] [Facultative] title of output
      def html_output(title = running_title)
        CommonFormatters::META + "\n<h3>#{title}</h3>\n" + @table.doc_for_html
      end

      # @return [String] html formatted output
      # @param lim [Integer] number of lines
      def html_sample(lim = 8)
        CommonFormatters::META + "\n<h3>#{running_title}</h3>\n" + @table.sample_for_html(lim)
      end

      # @param [Path] path path of file to be produced
      # @param [String] titre title of report
      # @param [Table] tbl table to process
      def self.prawn_generate(path, titre, tbl)
        Prawn::Document.generate(path) do
          text(titre, align: :center, size: 15)
          move_down 10
          font_size 9
          table(tbl.doc_for_pdf, CommonFormatters::PRAWN_FORMAT) unless tbl.empty?
        end
      end
    end
  end
end

__END__
