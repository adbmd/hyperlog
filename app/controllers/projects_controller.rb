class ProjectsController < ApplicationController
  layout 'user'

  before_action do
    @profile = current_user.profile
    @selectable_repos = @profile.profile_repo_analyses.all.select do |pr|
      pr.project.nil?
    end.map(&:repo)
    @projects = @profile.projects
  end

  def index; end

  def new; end

  def show
    @project = @projects.find(params[:id])
  end

  def edit
    @project = @projects.find(params[:id])
  end

  def create
    create_params = project_params.merge(profile: current_user.profile)
    selected_repos = JSON.parse(create_params.delete(:repos))
    selected_repos = selected_repos.map do |repo|
      @profile.repos.find(repo.fetch('id'))
    end
    project_image = create_params.delete(:project_image)

    @project = Project.create(create_params)

    if @project.persisted?
      # do next two steps only if project was created successfully
      selected_repos.each { |repo| @project.add_repo(repo) }
      unless project_image.nil?
        begin
          @project.set_image(project_image)
        rescue StandardError => e
          redirect_to project_new_path, alert: e.message
          return
        end
      end
      redirect_to projects_home_path, notice: 'Project created successfully!'
    elsif @project.errors.key?(:profile)
      redirect_to project_new_path,
                  alert: 'Something went wrong.' \
                         ' Did you try to create more than 5 projects?'
    else
      redirect_to project_new_path,
                  alert: @project.errors.full_messages.join(', ')
    end
  end

  def update
    @project = @projects.find(params[:id])
    update_params = project_params
    selected_repos = JSON.parse(update_params.delete(:repos))
    selected_repos = selected_repos.map do |repo|
      @profile.repos.find(repo.fetch('id'))
    end
    project_image = update_params.delete(:project_image)

    if @project.update(update_params)
      @project.profile_repo_analyses.each do |pr_analysis|
        pr_analysis.update!(project: nil)
      end
      # @project.aggregate_analysis
      selected_repos.each do |repo|
        @project.add_repo(repo)
      end
      unless project_image.nil?
        begin
          @project.set_image(project_image)
        rescue StandardError => e
          redirect_to edit_project_path(@project), alert: e.message
          return
        end
      end
      redirect_to edit_project_path(@project), notice: 'Updated successfully!'
    else
      redirect_to edit_project_path(@project), alert: 'Something went wrong'
    end
  end

  private

  def project_params
    params.require(:project).permit(:name, :tagline, :description,
                                    :repos, :project_image)
  end
end
