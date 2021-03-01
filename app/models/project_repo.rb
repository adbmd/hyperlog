class ProjectRepo < ApplicationRecord
  belongs_to :project
  belongs_to :repo

  before_create do |project_repo|
    repo_name = project_repo.repo.full_name
    repos_info = project_repo.project.profile.github.repos
    self.occurences = repos_info.dig(repo_name, 'occurences')
  end

  validates :repo, uniqueness: { scope: :project }

  def tech_analysis
    project.profile.tech_analysis.dig('repos', repo.full_name)
  end
end
