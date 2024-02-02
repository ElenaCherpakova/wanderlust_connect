class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  # def after_sign_up_path_for(_resource)
  #   dashboard_path
  # end

  # def after_sign_in_path_for(_resource)
  #   dashboard_path
  # end

  # Custom 404 error handling
  def render_404
    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end

  def not_found_method
    render_404
  end
end
