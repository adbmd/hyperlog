class DataApiController < ActionController::API
  before_action :extract_portfolio_user
  # before_action :validate_portfolio_user
  before_action :skip_origin_validation

  # GET /user_info
  def user_info
    user_info = user_info_from_user(@portfolio_user)
    user_socials = user_socials_from_user(@portfolio_user)
    user_contacts = user_contacts_from_user(@portfolio_user)

    user_info.merge!(social_links: user_socials, contact_info: user_contacts)

    render json: user_info
  end

  # GET /user_socials
  def user_socials
    render json: socials_with_prefix
  end

  # GET /projects
  def projects
    render json: projects_info_from_profile(@portfolio_user.profile)
  end

  # GET /projects/:id
  def project_info
    project = @portfolio_user.profile.projects.friendly.find(params[:id])
    render json: project_info_from_project(project)
  end

  # GET /projects/:project_id/repos/:repo_id
  def project_repo
    project_id, repo_id = params.values_at(:project_id, :repo_id)

    project = @portfolio_user.profile.projects.friendly.find(project_id)
    repo = project.repos.friendly.find(repo_id)

    render json: repo_info_from_project_and_repo(project, repo)
  end

  private

  def extract_portfolio_user
    portfolio_user_id = request.headers['x-portfolio-user-id']

    if portfolio_user_id.nil?
      render json: { message: 'x-portfolio-user-id header is required' },
             status: :bad_request
    else
      begin
        @_portfolio_user = User.find(portfolio_user_id)
      rescue ActiveRecord::RecordNotFound
        render json: { message: 'User not found' },
               status: :not_found
      end
    end
  end

  # def validate_portfolio_user
  #   request_origin = request.headers.fetch('origin')
  #   portfolio_username, _domain = request_origin.split('.', 2)

  #   if @_portfolio_user.username == portfolio_username
  #     @portfolio_user = @_portfolio_user
  #   else
  #     render json: { message: "Portfolio ID doesn't match subdomain" },
  #            status: :bad_request
  #   end
  # end

  def skip_origin_validation
    @portfolio_user = @_portfolio_user
  end

  def user_info_from_user(user)
    user_attributes = user.as_json only: %i[username first_name last_name]
    profile_attributes = user.profile.as_json only: %i[tagline about]
    user_attributes.merge(profile_attributes)
  end

  def user_socials_from_user(user)
    raw_socials = user.profile.social_links.symbolize_keys
    {}.tap do |socials|
      raw_socials.each do |provider, username|
        next if username.blank?

        socials[provider] = {
          url_prefix: "https://#{Profile.base_social_links.fetch(provider)}",
          username: username
        }
      end
    end
  end

  def user_contacts_from_user(user)
    user.profile.contact_info
  end

  def projects_info_from_profile(profile)
    profile.projects.map { |proj| project_info_from_project(proj) }
  end

  def project_info_from_project(project)
    project.as_json(
      only: %i[id name slug tagline description image_url
               aggregated_tech_analysis],
      include: {
        repos: {
          only: %i[id slug full_name description primary_language stargazers
                   image_url],
          methods: :html_url
        }
      }
    )
  end

  def repo_info_from_project_and_repo(project, repo)
    repo_attributes = repo.as_json only: %i[id full_name slug description image_url
                                            primary_language stargazers image_url analysis]
    pr_analysis = project.profile_repo_analyses.where(repo: repo).first
    pr_analysis_attributes = pr_analysis.as_json only: %i[contributions
                                                          tech_analysis]
    repo_attributes.merge(pr_analysis_attributes)
  end
end
