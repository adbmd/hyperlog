class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    # Take omniauth info, if another user is already authenticated,
    # try to add github omniauth on that user
    # if not,
    # and create an account with github-provided details
    if user_signed_in?
      @user = current_user
      return redirect_to :home_index_path, alert: 'A GitHub account is already connected' if @user.has_github_oauth?

      if @user.add_omniauth(request.env['omniauth.auth'])
        redirect_to :home_index_path, notice: 'GitHub connected successfully!'
      else
        redirect_to :home_index_path, alert: 'Couldn\'t connect with GitHub account'
      end
    else
      user = User.from_omniauth(request.env['omniauth.auth'])
      if user
        @user = user
        sign_in_and_redirect @user
      else
        redirect_to new_user_session_path,
                    alert: "Sign-ups are disabled because we are currently in closed beta.<br />" \
                           "We are delighted to know that you're excited about Hyperlog! " \
                           "Join the waitlist here at <a href='https://hyperlog.io'><u>Hyperlog.io</u></a> " \
                           "to be among the first to get access as we open up.",
                    flash: { html_alert: true }  # a hacky way to pass parameters, remove this later
      end
    end
  end
end
