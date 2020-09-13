class SessionsController < ApplicationController

  def new
    redirect_to "/" and return if current_user
    render 'sessions/new'
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)
    if user && RateLimiter.allowed?(:sign_in, "login:#{user.id}") && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to '/notifications'
    else
      flash.now[:error] = "Invalid email or password"
      render 'sessions/new'
    end
  end

  def destroy
    session.destroy
    redirect_to '/'
  end

end
