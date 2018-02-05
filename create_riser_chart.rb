# frozen_string_literal: true

require 'English'
require 'json'
require 'pp'
require 'erb'
require 'json'
require 'csv'
require 'fileutils'
require_relative 'lib/riser_chart'

puts <<-DOC
======================================================
           GMCLA RISER CHART GENERATOR 0.2
======================================================
  You will need:
    \e[36mchorus_members.json\e[0m (from Chorus Connection Members page)
    \e[36mriser_chart.json\e[0m (from a the Chorus Connection edit riser chart page)

  Put these files in a new directory before continuing.

DOC

print 'Season Directory: '

target_folder = gets.chomp
unless Dir.exist?(target_folder)
  puts 'Error! Invalid folder path'
  exit
end

['chorus_members.json', 'riser_chart.json'].each do |f|
  unless File.exist? "#{target_folder}/#{f}"
    puts "Error! Target directory must contain #{f}"
    exit
  end
end

RiserChart.generate!(target_folder)
