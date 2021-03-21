class Project < ApplicationRecord
  belongs_to :profile

  has_many :profile_repo_analyses, -> { distinct }, dependent: :nullify
  has_many :repos, -> { distinct }, through: :profile_repo_analyses

  validates :profile, presence: true
  validates :name, presence: true
  validates :tagline, presence: true

  validates_associated :profile

  validate :validate_number_of_repos
  validate :validate_analysis_profiles_must_match_project_profile

  after_initialize :set_defaults
  before_create do
    self.image_url ||= if repos.length.positive?
                         repos[0].image_url
                       else
                         profile.github.user_profile['avatar_url']
                       end
  end

  def set_defaults
    return unless new_record?

    self.tagline ||= name
    self.description ||= ''
  end

  def add_repo(repo)
    prof_repo_analysis = repo.profile_repo_analyses.find_by!(profile: profile)
    profile_repo_analyses << prof_repo_analysis
    # update aggregated_tech_analysis
    aggregate_analysis
    repo.reload
  end

  def remove_repo(repo)
    prof_repo_analysis = repo.profile_repo_analyses.find_by!(profile: profile)
    prof_repo_analysis.update!(project: nil)
    # update aggregated_tech_analysis
    aggregate_analysis
    repo.reload
  end

  def start_repo_analysis(force: false)
    repos_hash = {}
    repos.each do |repo|
      # analyse if force is true or last analysis is more than a week old
      if force || repo.analysis.nil? || repo.analysis['fetched_at'].to_datetime < Time.now - 7.days
        repos_hash[repo.full_name] = { id: repo.id }
      end
    end

    return if repos_hash.empty?

    url = Rails.configuration.x.repos.repo_analysis_invocation_url

    response = Faraday.post(url) do |req|
      req.body = {
        repos: repos_hash,
        token: profile.github.access_token
      }.to_json
    end

    if response.success?
      response.body
    else
      raise "Repo analysis failed with status #{response.status}:" \
            " #{response.body}"
    end
  end

  def aggregate_analysis
    # initialize new hash, we'll fully recompute the overall analysis
    aggregated = { libs: {}, tags: {}, tech: {} }
    profile_repo_analyses.pluck(:tech_analysis).each do |tech_analysis|
      tech_analysis.symbolize_keys!
      # category is one of [:libs, :tech, :tags]
      tech_analysis.each do |category, category_stats|
        # specific_key is the id of the lib, tech or tag
        # e.g. it can be 'rb.rails' (as library) or 'framework' (as a tag)
        category_stats.each do |specific_key, stats|
          unless aggregated[category].key?(specific_key)
            aggregated[category][specific_key] =
              initial_stats_unit_for_tech_analysis
          end

          aggregated[category][specific_key][:insertions] += stats['insertions']
          aggregated[category][specific_key][:deletions] += stats['deletions']
        end
      end
    end

    self.aggregated_tech_analysis = aggregated
    save!

    aggregated_tech_analysis
  end

  private

  def max_repos
    5
  end

  def validate_number_of_repos
    if repos.length > max_repos
      errors.add(:repos,
                 "Each project should contain no more than #{max_repos} repos")
    end
  end

  def validate_analysis_profiles_must_match_project_profile
    profile_repo_analyses.each do |pr_analysis|
      unless profile == pr_analysis.profile
        errors.add(:profile_repo_analyses,
                   "Profile on project doens't match profile on analysis for repo #{pr_analysis.repo.full_name}")
      end
    end
  end

  def initial_stats_unit_for_tech_analysis
    { insertions: 0, deletions: 0 }
  end
end
