class Repo < ApplicationRecord
  validates :provider_repo_id, uniqueness: { scope: :provider }
end
