class Repo < ApplicationRecord
  has_one :project, dependent: :destroy

  validates :provider_repo_id, uniqueness: { scope: :provider }
end
