class UsersController < ApplicationController
  before_action :require_login

  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])

    if @user == nil
      render_404
    end
    render_404 unless @user.id == session[:user_id]
  end
end
