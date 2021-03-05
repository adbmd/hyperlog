class ProfileRepoAnalysis < ApplicationRecord
  belongs_to :profile
  belongs_to :repo
  belongs_to :project, optional: true

  validates :repo, uniqueness: { scope: :profile }
end
