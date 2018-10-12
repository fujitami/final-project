class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  def update_resource(resource, params)
    resource.update_without_current_password(params)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :icon])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :icon])
  end

  protected

  def after_update_path_for(resource)
    user_path(current_user)
  end

end
