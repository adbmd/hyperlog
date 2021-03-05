class SettingsController < ApplicationController
  layout 'settings'
  def profile
    @base_social_links = Profile.base_social_links
    @social_links = current_user.profile.social_links.symbolize_keys
    @user = current_user
  end

  def account; end

  def themes; end

  def password; end

  def profile_edit
    user = User.find(current_user.id)
    if user.update(profile_params)
      redirect_to profile_path,
                  notice: 'Updated Successfully'
    else
      redirect_to profile_path,
                  alert: 'Something went wrong. Please try again.'
    end
  end

  def social_edit
    profile = current_user.profile

    if profile.update(social_params)
      redirect_to profile_path,
                  notice: 'Updated Successfully'
    else
      redirect_to profile_path,
                  alert: 'Something went wrong. Please try again.'
    end
  end

  def profile_params
    params.require(:user).permit(:first_name, :last_name)
  end

  def social_params
    params.require(:profile).permit(:tagline,
                                    social_links: Profile.valid_socials)
  end

  private

  def resource_name
    :user
  end
  helper_method :resource_name

  def resource
    @resource ||= User.new
  end
  helper_method :resource

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
  helper_method :devise_mapping

  def resource_class
    User
  end
  helper_method :resource_class
end
