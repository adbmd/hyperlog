class Project < ApplicationRecord
  belongs_to :profile, dependent: :destroy
  belongs_to :repo, dependent: :destroy

  validates :repo, presence: true, uniqueness: true
  validates :profile, presence: true

  after_initialize :set_defaults
  before_create do
    self.image_url ||= repo.image_url unless repo.nil?
  end

  def set_defaults
    return unless new_record?

    self.tagline ||= name
    self.description ||= ''
  end

  def tech_analysis
    profile.tech_analysis['repos'][repo.full_name] unless repo.nil?
  end

  def occurences
    profile.github.repos.dig(repo.full_name, 'occurences')
  end
end
