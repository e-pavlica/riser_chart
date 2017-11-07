# frozen_string_literal: true

class Wedge
  DIMENSIONS = [
    { step: 'Floor', width: 36.4 },
    { step: 1, width: 36.4 },
    { step: 2, width: 42.8 },
    { step: 3, width: 49.1 },
    { step: 4, width: 55.5 },
    { step: 5, width: 61.9 },
    { step: 6, width: 68.2 },
    { step: 7, width: 74.6 },
    { step: 8, width: 81.0 },
    { step: 9, width: 87.3 }
  ].freeze

  attr_reader :rows

  def initialize(space)
    @rows = build_rows(space)
  end

  def build_rows(space)
    DIMENSIONS.map do |dim|
      Row.new(dim[:width], dim[:step], space)
    end
  end

  def fill_wedge(singers)
    idx = 0
    rows.each do |row|
      row.spaces.times do
        row.add_singer(singers[idx])
        idx += 1
      end

      row.sort_by_section!
    end
  end

  def available_spaces
    @available_spaces ||= rows.collect(&:spaces).reduce(:+)
  end
end
