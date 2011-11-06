class ApplicationController < ActionController::Base
  protect_from_forgery
  force_ssl
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
  
  private
  
  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end
  
  def admin?
    current_user.admin?
  end
  
  def blocked?
    current_user.block?
  end
  
  def authenticate!
    if !current_user
      redirect_to(root_url, alert: 'Authentication required.')
    elsif current_user.blocked?
      redirect_to(root_url, alert: 'Your account is blocked.')
    end
  end
  
  def admin_authenticate!
    redirect_to(root_url, alert: 'Admin authentication required.') unless current_user && current_user.admin?
  end
  
  def not_authenticated
    redirect_to login_url, alert: 'First login to access this page.'
  end
  
  helper_method :current_user, :admin?, :blocked?
end
