#!/usr/bin/env ruby
# encoding: utf-8

# File: report_formatters.rb
# Created: 28/03/12
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  module Reports
    # formatters methods for classes Report and Bundle
    module CommonFormatters
      # header for html files
      META = '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>'

      # Prawn format for tables
      PRAWN_FORMAT = { cell_style: { inline_format: true },
                       row_colors: %w(F0F0F0 FFFFCC), header: true }

      # @return [String] time stamp fir filenames
      def self.time_stamp
        Time.now.strftime('%Y%m%d-%H%M%S')
      end

      # @return [String] default filenames for output
      def default_name
        J2R.correct(title) + '_' + CommonFormatters.time_stamp
      end

      # produce and save html formatted output
      # @param name [String] [Facultative] raw name of output file
      # @return [String] full path of output file
      def to_html_user_file(name = default_name)
        CommonFormatters.to_user_file(name + '.html', html_output)
      end

      # produce and save html formatted output
      # @param path [Path] path of output file
      # @return [Path] path of output file
      def to_html_file(path)
        J2R.to_file(path, html_output)
      end

      # produce and save txt formatted output
      # @param name [String] [Facultative] raw name of output file
      # @return [String] full path of output file
      def to_txt_user_file(name = default_name)
        CommonFormatters.to_user_file(name + '.txt', txt_output)
      end

      # @param filename [Filename] name of output file
      # @param output [Object] formatted output to save
      # @return [String] full path of output file
      # @param encoding [String] name of encoding, default "utf-8"
      def self.to_user_file(filename, output, encoding = 'utf-8')
        path = File.expand_path(filename, User.sorties)
        J2R.to_file(path, output, encoding)
      end

      # @return [Path] temporary html file
      def temp_html
        J2R.to_temp_file('.html', html_output)
      end
    end
  end
end
