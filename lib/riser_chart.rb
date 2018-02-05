# frozen_string_literal: true

require_relative 'row'
require_relative 'wedge'
require_relative 'chorus_member'

class RiserChart
  SECTIONS = ['B1', 'B2', 'T1', 'T2'].freeze
  WEDGE_COUNT = 8
  STARTING_SPACE = 20.0

  attr_reader :singers, :wedges

  def self.generate!(target_dir)
    new(target_dir)
  end

  def initialize(target_dir)
    @space = STARTING_SPACE
    @target_dir = target_dir
    parsed = parse_riser_data
    @singers = sort_singers(parsed)
    prepare_chart
    dir = "#{@target_dir}/chart_#{Time.now.strftime('%Y%m%d_%H%M%S')}"
    FileUtils.mkdir(dir)
    FileUtils.cd(dir) do
      present!
    end
  end

  def prepare_chart
    @wedges = build_chart(WEDGE_COUNT, @space)
    fill_chart(@wedges, singers)
  rescue UnplacedSinger
    if @space > 10.0
      @space -= 0.2
      retry
    else
      raise TooManySingers
    end
  end

  def active_ids
    @active ||= begin
                  json = File.read("#{@target_dir}/chorus_members.json")
                  data = JSON.parse(json)
                  data.map { |m| m['id'] if m['status'] == 'Active' }.compact
                end
  end

  def parse_riser_data
    data = JSON.parse(File.read("#{@target_dir}/riser_chart.json"))
    data['unplaced_singers'].map do |record|
      singer = record['chorus_member']
      next unless active_ids.include?(singer['id'])
      name = "#{singer['first_name']} #{singer['last_name']}"
      height = singer['height']
      section = singer['section']
      split = singer['section_split']
      ChorusMember.new(name, section, split, height)
    end.compact
  end

  def build_chart(wedges, space)
    wedges.times.with_object([]) do |_i, arr|
      arr << Wedge.new(space)
    end
  end

  def build_csv(wedges)
    flattened = wedges.each_with_object({}) do |wedge, hash|
      wedge.rows.reverse.each do |row|
        if hash[row.step].nil?
          hash[row.step] = row.singers
        else
          hash[row.step] += row.singers
        end
      end
    end

    SECTIONS.each do |section|
      CSV.open("#{section}.csv", 'wb') do |csv|
        flattened.each do |step, singers|
          presented_singers = singers.select { |s| s.section == section }
                                     .collect { |s| s.present(false) }
          csv << [step] + presented_singers
        end
      end
    end
  end

  def fill_chart(wedges, singers)
    singer_idx = 0
    wedges.each do |wedge|
      num_singers = wedge.available_spaces
      wedge_singers = singers.slice(singer_idx, num_singers)
      next if wedge_singers.nil?
      sorted = wedge_singers.compact.sort_by(&:height)
      wedge.fill_wedge(sorted)
      singer_idx += num_singers
    end

    unplaced = singers.slice(singer_idx, singers.length - 1)
    if unplaced
      # puts "\e[31mUnplaced Singers: #{unplaced.length}, space: #{@space}\e[0m"
      # puts unplaced.compact.collect(&:name).join(' | ')
      raise UnplacedSinger
    else
      # puts "\e[32mNo unplaced singers\e[0m"
    end
  end

  def sort_singers(parsed)
    sections = parsed.group_by(&:section)
    SECTIONS.map do |section_name|
      split = sections[section_name].group_by(&:split)
      [split['upper'], split['lower']]
    end.flatten
  end

  def present!
    render_chart(binding)
    build_csv(@wedges)
  end

  def render_chart(*args)
    template = File.read(File.join(__dir__, 'chart.svg.erb'))
    svg = ERB.new(template).result(*args)
    file_name = 'chart.svg'
    File.open(file_name, 'w') do |f|
      f << svg
    end
    puts "\e[32mRiser chart rendered to #{FileUtils.pwd}/#{file_name}\e[0m"
    puts "Singers will have \e[33m#{@space.round(2)} inches\e[0m of space each."
  end

  class Error < StandardError; end
  class UnplacedSinger < Error; end
  class TooManySingers < Error; end
end
