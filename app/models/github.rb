class Github < ApplicationRecord
  belongs_to :profile

  validates :uid, uniqueness: true

  def start_initial_analysis(deep_analysis: true)
    url = Rails.configuration.x.profiles.initial_analysis_invocation_url

    response = Faraday.post(url) do |req|
      req.body = {
        user_id: profile.user_id,
        token: access_token,
        deep_analysis: deep_analysis
      }.to_json
    end
    raise "Initial analysis failed with status code #{response.status}:\n#{response.body}" unless response.success?
  end
end
