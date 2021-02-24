class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def after_update_path_for(_resource)
    login_path
  end
end
