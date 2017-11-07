# frozen_string_literal: true

class ChorusMember
  attr_accessor \
    :name,
    :section,
    :split,
    :height,
    :center

  SECTION_VALUES = {
    'B1' => 1,
    'B2' => 2,
    'T1' => 3,
    'T2' => 4,
    'upper' => 0,
    'lower' => 10
  }.freeze

  def initialize(name, section, split, height)
    @name = name
    @section = section
    @split = split
    @height = height || 70
  end

  def present(center = true)
    if center
      "#{name} (#{height}) @#{center}"
    else
      "#{name} (#{height})"
    end
  end

  def section_class
    section.downcase.tr(' ', '-')
  end

  def weighted_section_value
    SECTION_VALUES[section] + SECTION_VALUES[split]
  end
end
