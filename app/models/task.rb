# frozen_string_literal: true

require 'nokogiri'
require 'zip'
class Task < ApplicationRecord
  acts_as_taggable_on :state

  groupify :group_member
  validates :title, presence: true

  validates :uuid, uniqueness: true

  has_many :files, as: :fileable, class_name: 'TaskFile', dependent: :destroy

  has_many :tests, dependent: :destroy
  has_many :model_solutions, dependent: :destroy

  belongs_to :user
  belongs_to :programming_language, optional: true

  accepts_nested_attributes_for :files, allow_destroy: true
  accepts_nested_attributes_for :tests, allow_destroy: true
  accepts_nested_attributes_for :model_solutions, allow_destroy: true

  # scope :text_like, lambda { |text|
  #   if text.present?
  #     where('title ILIKE ? OR description ILIKE ?', "%#{text}%", "%#{text}%")
  #   else
  #     where(nil)
  #   end
  # }

  scope :visibility, ->(visibility, user = nil) { {owner: where(user: user), public: all}.with_indifferent_access[visibility] }
  scope :created_before_days, ->(days) { where(created_at: days.to_i.days.ago.beginning_of_day..) if days.to_i.positive? }

  def self.ransackable_scopes(auth_object = nil)
    %i[created_before_days]
  end
  # will be replaced with ransack
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.search(search, settings, option, user_param)
    case option
    when 'private'
      priv = true
      user = nil
    when 'public'
      priv = false
      user = nil
    else
      priv = nil
      user = user_param
    end
    stars = '0'
    intervall = 0

    if settings
      stars = settings[:stars]
      intervall = settings[:created].to_i
      if settings[:language]
        languages = settings[:language]
        languages.delete_at(0) if languages[0].blank?
      end
      if settings[:proglanguage]
        proglanguages = settings[:proglanguage]
        proglanguages.delete_at(0) if proglanguages[0].blank?
        proglanguages = proglanguages.collect { |x| ProgrammingLanguage.find_by(language: x).id }
      end
    end

    search_query(stars, languages, proglanguages, priv, user, search, intervall) # unless search
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def can_access(user)
    self.user == user
  end
end
