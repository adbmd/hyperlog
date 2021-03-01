class Project < ApplicationRecord
  belongs_to :profile, dependent: :destroy

  has_many :project_repos, dependent: :destroy
  has_many :repos, through: :project_repos

  validates :profile, presence: true

  validate :validate_number_of_repos

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

  def tech_analysis
    profile.tech_analysis['repos'][repo.full_name] unless repo.nil?
  end

  def add_repo(repo)
    repos << repo
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
end
