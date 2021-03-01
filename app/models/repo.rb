class Repo < ApplicationRecord
  has_many :project_repos, dependent: :destroy
  has_many :projects, through: :project_repos

  validates :provider_repo_id, uniqueness: { scope: :provider }
end
