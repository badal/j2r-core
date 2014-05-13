#!/usr/bin/env ruby
# encoding: utf-8

# File: batch_reporter.rb
# Created: 02/04/12
#
# (c) Michel Demazure <michel@demazure.com>

require 'optparse'

require_relative '../../../lib/j2r'

module JacintheReports
  module Recipes
    # batch reporter for Jacinthe
    module BatchReporter
      # help message
      HELP = <<FIN
 Usage : (ruby) batch_reporter.rb [options]

 Le programme 'batch_reporter' produit des rapports
 - à partir d'une maquette
 - sous l'un des formats txt, html, pdf, csv
 - (les formats txt et csv ne sont pas disponibles pour les rapports éclatés).

 L'extension du fichier de sortie doit être .txt, .html, .pdf, ou .csv .

 Les options sont :

    -I, --Input PATH                 Chemin absolu du fichier d'entrée.
    -i, --input PATH                 Chemin relatif du fichier d'entrée.
    -O, --Output PATH                Chemin absolu du fichier de sortie.
    -o, --output PATH                Chemin relatif du fichier de sortie.
    -h, --help                       Court message d'aide.
    -H, --Help                       Long message d'aide.
    -v, --version                    Version du programme.

 La présence de l'une exactement des options -I et -i,
 et de l'une exactement des options -O et -o, est obligatoire.
FIN

      # @param args [Array] args of command
      # @return [Hash] options
      # FLOG: 30.0
      def self.parse(args) # rubocop:disable MethodLength
        params = {}
        parser = OptionParser.new do |opts|
          opts.banner = 'Usage: batch_reporter options'
          opts.separator ''
          opts.separator 'Options:'
          opts.on('-I', '--Input PATH', 'Chemin absolu du fichier d\'entrée.') do |abs_inp_path|
            params[:Input] = abs_inp_path
          end
          opts.on('-i', '--input PATH', 'Chemin relatif du fichier d\'entrée.') do |rel_inp_path|
            params[:input] = rel_inp_path
          end
          opts.on('-O', '--Output PATH', 'Chemin absolu du fichier de sortie.') do |abs_out_path|
            params[:Output] = abs_out_path
          end
          opts.on('-o', '--output PATH', 'Chemin relatif du fichier de sortiee.') do |rel_out_path|
            params[:output] = rel_out_path
          end
          opts.on_tail('-h', '--help', 'Ce message d\'aide court.') do
            error(opts)
          end
          opts.on_tail('-H', '--Help', 'Long essage d\'aide.') do
            error(HELP)
          end
          opts.on_tail('-v', '--version', 'Version du programme.') do
            error(J2R::NAME)
          end
        end

        begin
          parser.parse!(args)
          error('Faire \'batch_processor -h pour connaître les options') if params.empty?
          params
        rescue => ex
          error('ERREUR ' + ex.message)
        end
      end

      # print error and exit
      # @param msg [String] error message
      def self.error(msg)
        puts msg
        exit
      end

      # check if only one path given, return path made absolute
      # @param relative [Path, nil] relative path
      # @param absolute [Path, nil] absolute path
      # @return [Path] absolute path
      def self.get_path(relative, absolute)
        if absolute
          relative ? nil : absolute
        elsif relative
          File.expand_path(relative, @dir)
        else
          nil
        end
      end

      # @param path [Path] yaml file path
      # @return [Object] object coded in the yaml file
      def self.get_content(path)
        yml = File.read(path, encoding: 'utf-8')
        Psych.load(yml)
      rescue Errno::ENOENT
        error("Pas de fichier #{path}")
      end

      # @return [Path] user ~ directory
      def self.user_dir
        case
        when J2R.win?
          ENV['USERPROFILE']
        when J2R.darwin?
          ENV['HOME']
        else
          nil
        end
      end

      # @param params [Hash] hash of parms
      # @return [Path, Path] imput path, output path
      def self.get_and_check_paths(params)
        input_path = get_path(params[:input], params[:Input])
        error('Une et une seule option -i ou -I !') unless input_path
        output_path = get_path(params[:output], params[:Output])
        error('Une et une seule option -o ou -O !') unless output_path
        [input_path, output_path]
      end

      # @param content [Array] array form of object
      # @return [Recipe] recipe
      def self.get_recipe_from(content)
        Recipe.from_hash(content)
      rescue
        error 'Fichier incorrect ou corrumpu'
      end

      # @param output_path [Path] file path
      # @return [Symbol] file extension
      def self.get_format(output_path)
        format = File.extname(output_path)[1..-1]
        test = format && %w(txt html csv pdf).include?(format)
        test ? format.to_sym : error("Pas de format nommé '#{format}'")
      end

      # run the reporter
      def self.run(args)
        @dir = user_dir
        params = BatchReporter.parse(args)
        input_path, output_path = *get_and_check_paths(params)
        content = get_content(input_path)
        recipe = get_recipe_from(content)
        format = get_format(output_path)
        process(recipe, output_path, format)
      end

      # @param recipe [Recipe] recipe to process
      # @param output_path [Path] output file
      # @param format [Symbol] format
      def self.process(recipe, output_path, format) # rubocop:disable MethodLength
        J2R.for_user do
          report = Reports::Report.new(recipe.table_for_report)
          # noinspection RubyCaseWithoutElseBlockInspection
          case format
          when :txt
            J2R.to_file(output_path, report.txt_output)
          when :html
            J2R.to_file(output_path, report.html_output)
          when :csv
            report.to_csv_file(output_path)
          when :pdf
            report.to_pdf_file(output_path)
          end
        end
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME

  J2R::Recipes::BatchReporter.run(ARGV)

end
