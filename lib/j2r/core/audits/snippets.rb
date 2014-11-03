#!/usr/bin/env ruby
# encoding: utf-8

# File: snippets.rb
# Created: 11/04/12
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  module Audits
    # HTML snippets for audits
    module Snippets
      # head of html file
      HEAD = <<HEAD_END
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>$TITLE</title>
    <script type="text/javascript" charset="utf-8" src=$JQUERY> </script>
    <script type="text/javascript" charset="utf-8" src=$APP> </script>
</head>
HEAD_END

      # @param [String] title title of html page
      # @return [String] head of html file
      def self.head(title)
        dir = File.dirname(__FILE__)
        jquery = File.join(dir, 'js/jquery.js')
        app = File.join(dir, 'js/app.js')
        HEAD.sub('$TITLE', title).sub('$JQUERY', "'file://#{jquery}'")
          .sub('$APP', "'file://#{app}'")
      end

      # @param [String, Array<String>] short_text always visible
      # @param [String, Array<String>] long_text visible when asked
      # @return [Array<String>] html snippet
      def self.extensible_element(short_text, long_text)
        ['<div class="for_details">', '<div>', short_text, '</div>',
         '<div class="details" style="display: none; padding: 3px 8px;\
 border-left: 8px solid #ddd; margin-top: 5px;">',
         long_text, '</div>', '</div>'].flatten
      end

      # @return [Array<String>] html snippet
      # @param [String] before first part of expansed title
      # @param [String] short_title middle (strong) part of title
      # @param [String] after third part of expansed title
      # @param [String, Array<String>] text text to show when displayed
      def self.summary_element(before, short_title, after, text)
        ['<li>', '<span class="summary_signature">',
         "<a>#{before} <strong>#{short_title}</strong> #{after}</a>",
         '</span>', '<span class="summary_desc">',
         '<p>', text, '</p>', '</span>', '</li>'].flatten
      end

      # @return [Array<String>] html snippet
      # @param [String] title of list
      # @param [Array] elements list of summary elements
      def self.summary_list(title, elements)
        ['<h2>', "#{title} <small>(<a href=\"#\" class=\"summary_toggle\">contracter</a>)</small>",
         '</h2>', '<ul class="summary">', elements, '</ul>'].flatten
      end
    end
  end
end
__END__
