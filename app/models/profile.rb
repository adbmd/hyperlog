class Profile < ApplicationRecord
  belongs_to :user
  has_one :github, dependent: :destroy

  after_initialize :set_defaults

  def set_defaults
    self.tech_analysis ||= { repos: {} }
  end
end
