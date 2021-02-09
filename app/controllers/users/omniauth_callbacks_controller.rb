class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    # Take omniauth info, if another user is already authenticated,
    # try to add github omniauth on that user
    # if not,
    # and create an account with github-provided details
    if user_signed_in?
      @user = current_user
      return render html: 'A GitHub account is already connected' if @user.has_github_oauth?

      if @user.add_omniauth(request.env['omniauth.auth'])
        render html: 'GitHub account connected successfully!'
      else
        render html: "Couldn't connect with GitHub account"
      end
    else
      @user = User.from_omniauth(request.env['omniauth.auth'])
      sign_in_and_redirect @user
    end
  end
end
