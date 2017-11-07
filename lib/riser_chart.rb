# frozen_string_literal: true

require_relative 'row'
require_relative 'wedge'
require_relative 'chorus_member'

class RiserChart
  SECTIONS = ['B1', 'B2', 'T1', 'T2'].freeze

  def self.generate!(number_of_wedges, space, target_dir)
    new(number_of_wedges, space, target_dir)
  end

  def initialize(wedges, space, target_dir)
    @target_dir = target_dir
    parsed = parse_riser_data
    singers = sort_singers(parsed)
    @wedges = build_chart(wedges, space)
    fill_chart(@wedges, singers)
    dir = "#{@target_dir}/chart_#{Time.now.strftime('%Y%m%d_%H%M%S')}"
    FileUtils.mkdir(dir)
    FileUtils.cd(dir) do
      present!
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
      puts Rainbow("Unplaced Singers: #{unplaced.length}").red
      puts unplaced.compact.collect(&:name).join(' | ')
    else
      puts Rainbow('No unplaced singers').green
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
    # @wedges.each_with_index do |wedge, w_idx|
    #   puts Rainbow("Wedge ##{w_idx + 1}").blue
    #   wedge.rows.reverse.each_with_index do |row, _idx|
    #     print "\t#{row.step}: #{row.singers.collect(&:present).join(' | ')}\n"
    #   end
    #   puts "===========\n"
    # end

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
    puts Rainbow("Check out #{FileUtils.pwd}/#{file_name}!").green
  end
end
