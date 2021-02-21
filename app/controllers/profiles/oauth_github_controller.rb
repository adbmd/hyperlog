class Profiles::OauthGithubController < ApplicationController
  def initialize
    super
    @oauth_client = OAuth2::Client.new(Rails.configuration.x.profiles.github_client_id,
                                       Rails.configuration.x.profiles.github_client_secret,
                                       authorize_url: 'https://github.com/login/oauth/authorize',
                                       site: 'https://api.github.com',
                                       token_url: 'https://github.com/login/oauth/access_token')
  end

  def oauth_initiate
    redirect_to @oauth_client.auth_code.authorize_url({scope: 'read:org,public_repo'})
  end

  def oauth_callback
    # exchange authorization_code for access_token
    begin
      token = @oauth_client.auth_code.get_token(params[:code])
    rescue OAuth2::Error => e
      return redirect_to home_index_path, alert: e.description
    end

    if current_user.profile.has_attribute?(:github)
      redirect_to home_index_path, alert: 'A GitHub account is already connected for analysis'
    else
      p = current_user.profile

      user_info = token.get('/user', headers: { Accept: 'application/vnd.github.v3+json' }).parsed
      p.github = Github.new(uid: user_info['id'], access_token: token.token)
      p.save

      p.github.start_initial_analysis

      redirect_to home_index_path, notice: 'GitHub connected successfully! 🎉'
    end
  end
end
