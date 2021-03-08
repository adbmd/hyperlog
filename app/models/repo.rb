class Repo < ApplicationRecord
  has_many :profile_repo_analyses, dependent: :destroy
  has_many :projects, through: :profile_repo_analyses

  validates :provider_repo_id, uniqueness: { scope: :provider }

  def html_url
    case provider
    when 'github'
      "https://github.com/#{full_name}"
    else
      raise "Can't expand HTML url for provider #{provider}"
    end
  end
end
