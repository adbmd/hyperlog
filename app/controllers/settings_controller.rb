class SettingsController < ApplicationController
  layout 'settings'
  def profile
    @user = current_user
  end

  def account; end

  def themes; end

  def password; end

  def profile_edit
    if params.has_key?(:first_name) && params.has_key?(:last_name)
      user = User.find(current_user.id)
      user.first_name = params[:first_name]
      user.last_name = params[:last_name]
      if user.valid?
        user.save!
        redirect_to profile_path,
                    notice: 'Updated Successfully'
      else
        redirect_to profile_path,
                    alert: 'Something went wrong. Please try again.'
      end
    end
  end

  def profile_params
    params.require(:user).permit(:first_name, :last_name)
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
