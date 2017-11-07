# frozen_string_literal: true

class Row
  attr_reader :spaces, :remaining_length, :singers, :step

  def initialize(length, step, space)
    @length = length
    @spaces, @remaining_length = length.divmod space
    @singers = []
    @step = step
  end

  def add_singer(singer)
    raise 'Too many singers!' unless singers.length < spaces
    return unless singer
    singer.center = find_next_center
    @singers << singer
  end

  def find_next_center
    space_width = @length / spaces
    center_space = space_width / 2
    center_space + (space_width * singers.length)
  end

  def sort_by_section!
    centers = singers.collect(&:center)
    sorted = singers.sort_by(&:weighted_section_value)
    # binding.pry if singers.map(&:name).include?('Brian Tillis')
    @singers = sorted.each_with_index do |singer, idx|
      singer.center = centers[idx]
    end
  end
end
