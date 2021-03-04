class Project < ApplicationRecord
  belongs_to :profile

  has_many :profile_repo_analyses, -> { distinct }, dependent: :nullify
  has_many :repos, -> { distinct }, through: :profile_repo_analyses

  validates :profile, presence: true

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
    repo.reload
  end

  def remove_repo(repo)
    prof_repo_analysis = repo.profile_repo_analyses.find_by!(profile: profile)
    prof_repo_analysis.update!(project: nil)
    repo.reload
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
end
