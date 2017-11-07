# frozen_string_literal: true

class ChorusMember
  attr_accessor \
    :name,
    :section,
    :split,
    :height,
    :center

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
end
