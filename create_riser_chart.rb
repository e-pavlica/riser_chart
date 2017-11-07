# frozen_string_literal: true

require 'English'
require 'json'
require 'pp'
require 'rainbow'
require 'pry'
require 'erb'
require 'json'
require 'csv'
require 'fileutils'
require_relative 'lib/riser_chart'

puts <<-DOC
======================================================
            RISER CHART GENERATOR 0.1
======================================================

Season Directory:
DOC

target_folder = gets.chomp
# file_name = gets.chomp
#
# file = File.join(File.expand_path(__dir__), file_name)
#
unless Dir.exist?(target_folder)
  puts 'Error! Invalid folder path'
  exit
end

["chorus_members.json", "riser_chart.json"].each do |f|
  unless File.exist? "#{target_folder}/#{f}"
    puts "Error! Target directory must contain #{f}"
    exit
  end
end


#
# raw_data = File.read(file)
# data = JSON.parse(raw_data)

puts 'Number of Wedges: '
wedges = gets.chomp.to_i

puts 'Space per singer: '
space = gets.chomp.to_f

RiserChart.generate!(wedges, space, target_folder)
