class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def after_update_path_for(_resource)
    login_path
  end

  def after_sign_up_path_for(_resource)
    setup_path
  end
end
