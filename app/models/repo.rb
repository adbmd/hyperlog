class Repo < ApplicationRecord
  has_many :profile_repo_analyses, dependent: :destroy
  has_many :projects, through: :profile_repo_analyses

  validates :provider_repo_id, uniqueness: { scope: :provider }
end
