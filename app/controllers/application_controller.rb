class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def render_404
    # DPR: this will actually render a 404 page in production
    raise ActionController::RoutingError.new('Not Found')
  end

  def require_login
    unless current_user
      flash[:status] = :alert
      flash[:result_text] = "You must be logged in to do that"
      redirect_to root_path
    end
  end

  private
  def current_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end
  end
end
