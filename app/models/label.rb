# frozen_string_literal: true

class Label < ApplicationRecord
  has_many :task_labels, dependent: :destroy
  has_many :tasks, through: :task_labels

  MAX_LENGTH = 30
  validates :name, presence: true, length: {minimum: 1, maximum: MAX_LENGTH}, uniqueness: {case_sensitive: false}
  validates :color, presence: true, format: {with: /\A[a-fA-F0-9]{6}\z/}

  before_validation :choose_label_color, if: -> { color.blank? }

  def font_color
    c_codes = color_codes
    l_value = (c_codes[0] * 0.2126) + (c_codes[1] * 0.7152) + (c_codes[2] * 0.0722)
    if l_value > 0.179
      '000000'
    else
      'ffffff'
    end

    # Based on: https://stackoverflow.com/questions/3942878/how-to-decide-font-color-in-white-or-black-depending-on-background-color
  end

  def color_codes
    color_code_hex.collect do |c|
      c = c.to_i(16)
      c /= 255.0
      c = if c <= 0.03928
            c / 12.92
          else
            ((c + 0.055) / 1.055)**2.4
          end
      c
    end
  end

  def color_code_hex
    [
      color[0] + color[1],
      color[2] + color[3],
      color[4] + color[5],
    ]
  end

  def choose_label_color
    self.color = COLORS[Digest::MD5.hexdigest(name).to_i(16) % 50]
  end

  COLORS = %w[
    809bce 95b8d1 b8e0d2 d6eadf eac4d5
    6c464f 9e768f 9fa4c4 b3cdd1 c7f0bd
    a30015 bd2d87 d664be df99f0 b191ff
    80a1c1 eee3ab d9cfc1 a77e58 ba3f1d
    2d3047 419d78 e0a458 ffdbb5 c04abc
    034732 008148 c6c013 ef8a17 ef2917
    9b1d20 3d2b3d 635d5c cbefb6 d0ffce
    ee6352 59cd90 3fa7d6 fac05e f79d84
    483c46 3c6e71 70ae6e beee62 f4743b
    c33c54 254e70 37718e 8ee3ef aef3e7
  ].freeze

  def to_h
    {
      id:,
      name:,
      color:,
      font_color:,
      used_by_tasks: (tasks.size if tasks.loaded?),
      created_at: created_at.to_fs(:rfc822),
      updated_at: updated_at.to_fs(:rfc822),
    }.compact
  end

  def to_s
    name
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[name]
  end

  def self.ransortable_attributes(_auth_object = nil)
    %w[id name created_at]
  end
end
