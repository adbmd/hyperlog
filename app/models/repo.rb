class Repo < ApplicationRecord
  has_many :profile_repo_analyses, dependent: :destroy
  has_many :profiles, through: :profile_repo_analyses
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

  def start_analysis(token)
    url = Rails.configuration.x.repos.repo_analysis_invocation_url

    response = Faraday.post(url) do |req|
      req.body = {
        repo_id: id,
        token: token
      }.to_json
    end

    unless response.success?
      raise "Repo analysis failed with status #{response.status}:" \
            " #{response.body}"
    end
  end
end
