class SettingsController < ApplicationController
  layout 'settings'
  def profile
    @base_social_links = Profile.base_social_links
    @social_links = current_user.profile.social_links.symbolize_keys
    @contact_info = current_user.profile.contact_info
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

  def contact_info_edit
    profile = current_user.profile

    params_object = contact_info_params

    if params_object.dig('contact_info', 'phone')
      phone = Phonelib.parse(params_object.dig('contact_info', 'phone'))
      params_object[:contact_info][:phone] =
        if phone.country_code
          phone.international
        else
          phone.e164
        end
    end

    if profile.update(params_object)
      redirect_to profile_path, notice: 'Updated successfully!'
    else
      redirect_to profile_path, alert: profile.errors.full_messages.to_sentence
    end
  end

  def profile_params
    params.require(:user).permit(:first_name, :last_name)
  end

  def contact_info_params
    params.require(:profile).permit(contact_info: %i[email phone location])
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
