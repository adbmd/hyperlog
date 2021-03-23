class SettingsController < ApplicationController
  layout 'settings'
  def profile
    @profile = current_user.profile
    @base_social_links = Profile.base_social_links
    @social_links = current_user.profile.social_links.symbolize_keys
    @contact_info = current_user.profile.contact_info
    @user = current_user
  end

  def account; end

  def themes
    @valid_themes = Profile.valid_themes
    @current_theme = current_user.profile.theme
  end

  def password; end

  def profile_edit
    user = User.find(current_user.id)

    params_object = profile_params

    avatar = params_object.delete(:avatar)
    unless avatar.nil?
      begin
        response = Cloudinary::Uploader.upload(avatar.to_io,
                                               folder: 'user_avatars/',
                                               public_id: current_user.id,
                                               width: 256,
                                               height: 256,
                                               gravity: 'face',
                                               crop: 'thumb')
      rescue CloudinaryException => e
        redirect_to profile_path,
                    alert: e.message
        return
      end
      params_object[:avatar_url] = response.fetch('url')
    end

    if user.update(params_object)
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

  def themes_edit
    profile = current_user.profile
    theme = Theme.find(theme_params[:theme])
    if profile.update(theme: theme)
      profile.start_theme_build
      redirect_to themes_path,
                  notice: 'Theme updated successfully! Your new portfolio' \
                          ' will be up in a few minutes'
    else
      redirect_to themes_path,
                  alert: profile.errors.full_messages.to_sentence
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

  private

  def profile_params
    params.require(:user).permit(:first_name, :last_name, :avatar)
  end

  def contact_info_params
    params.require(:profile).permit(contact_info: %i[email phone location])
  end

  def social_params
    params.require(:profile).permit(:tagline,
                                    social_links: Profile.valid_socials)
  end

  def theme_params
    params.require(:theme).permit(:theme)
  end

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
