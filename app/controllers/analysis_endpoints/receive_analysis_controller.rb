class AnalysisEndpoints::ReceiveAnalysisController < ActionController::Base
  # inherit from ActionController::Base instead of ApplicationController
  # to bypass authentication setup for users
  TOKEN = ENV['ANALYSIS_ENDPOINTS_AUTH_TOKEN']

  before_action :authenticate
  skip_before_action :verify_authenticity_token # disable csrf

  # POST /initial_analysis
  def receive_initial_analysis
    data = params[:data]

    profile = User.find(params[:user_id]).profile
    g = profile.github
    if g.nil?
      return render json: { success: false, message: 'GitHub not connected' },
                    status: :bad_request
    end

    g.user_profile = data[:user_profile]
    g.save!

    data[:repos].each_value do |repo_info|
      repo = Repo.where(provider: 'github',
                        provider_repo_id: repo_info['repo_id']).first_or_create do |repo|
        repo.full_name = repo_info.fetch('full_name')
        repo.avatar_url = repo_info['avatar_url']
        repo.description = repo_info['description']
        repo.is_private = repo_info['is_private']
        repo.primary_language = repo_info['primary_language']
        repo.stargazers = repo_info['stargazers']
        repo.image_url = repo_info['image_url']
      end

      p_repo_analysis = ProfileRepoAnalysis.where(profile_id: profile,
                                                  repo: repo).first_or_create
      p_repo_analysis.update!(contributions: repo_info['occurences'])
    end

    profile.update_analysis_status

    render json: { success: true }
  end

  # POST /tech_analysis
  def add_tech_analysis_by_repo
    repo_name = params[:repo_full_name]
    data = params[:data]

    profile = User.find(params[:user_id]).profile
    repo = Repo.find_by!(provider: 'github', full_name: repo_name)

    prof_repo_analysis = ProfileRepoAnalysis.find_by!(profile: profile,
                                                      repo: repo)
    prof_repo_analysis.tech_analysis = {
      libs: data['libs'],
      tech: data['tech'],
      tags: data['tags']
    }
    prof_repo_analysis.save!

    profile.update_analysis_status

    render json: { success: true }
  end

  # POST /tech_analysis/status
  def tech_analysis_status
    user_id, repo_name, event = tech_analysis_status_params
                                .values_at(:user_id, :repo_full_name, :event)
    profile = User.find(user_id).profile

    if event == 'start'
      # analysis started
      repo = Repo.find_by!(provider: 'github',
                           full_name: repo_name)
      profile.analysis_status['current_repo'] = {
        id: repo.id,
        name: repo.full_name,
        url: "https://github.com/#{repo.full_name}"
      }
      profile.save!
      render json: { success: true }
    else
      render json: { success: false, message: "Unknown event #{event}" }
    end
  end

  private

  def authenticate
    authenticate_or_request_with_http_token do |token, _|
      ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
    end
  end

  def tech_analysis_status_params
    params.permit(:user_id, :repo_full_name, :event)
  end
end
