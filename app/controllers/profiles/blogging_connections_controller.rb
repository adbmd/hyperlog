class Profiles::BloggingConnectionsController < ApplicationController
  # def initialize
  #   super
  #   @devto_oauth = OAuth2::Client.new(Rails.configuration.x.profiles.devto_client_id,
  #                                     Rails.configuration.x.profiles.devto_client_secret,
  #                                     authorize_url: 'https://dev.to/oauth/authorize',
  #                                     site: 'https://dev.to/api',
  #                                     token_url: 'https://dev.to/oauth/token')
  # end

  # def hashnode_connection
  # end

  # def devto_oauth_initialize
  #   redirect_to @oauth_client.auth_code.authorize_url
  # end

  # def devto_oauth_callback
  #   # exchange authorization_code for access_token
  #   begin
  #     token = @oauth_client.auth_code.get_token(params[:code])
  #   rescue OAuth2::Error => e
  #     return redirect_to setup_path, alert: e.description
  #   end

  #   prof = current_user.profile
  #   if prof.blogging_connections.key?("devto")
  #     redirect_to blogs_path,
  #                 alert: 'A Dev.to account is already connected for you'
  #   else
  #     user_info = token.get('/users/me')
  #     prof.blogging_connections["devto"] = {
  #       access_token: token.token,
  #       id: user_info['id'],
  #       username: user_info['username']
  #     }
  #     prof.save!
  #     prof.sync_devto_blogs
  #     redirect_to blogs_path, notice: 'Dev.to connected successfully'
  #   end
  # end
end