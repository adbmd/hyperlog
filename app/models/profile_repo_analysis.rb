class ProfileRepoAnalysis < ApplicationRecord
  belongs_to :profile
  belongs_to :repo
  belongs_to :project, optional: true

  after_initialize :set_defaults

  validates :repo, uniqueness: { scope: :profile }

  private

  def set_defaults
    return unless new_record?

    self.tech_analysis ||= { tech: {}, tags: {}, libs: {} }
  end
end
