class UsersController < ApplicationController

  def new
    if logged_in?
      redirect_to '/'
    else
      render 'users/new'
    end
  end

  def create
    if logged_in?
      redirect_to '/'
      return
    end

    unless RateLimiter.allowed?(:register, registration_rate_limit_key)
      render plain: 'Rate limit exceeded', status: 429
      return
    end

    user = User.new(user_creation_params)
    if user.save
      session[:user_id] = user.id
      flash[:success] = "Your account has been created."
      redirect_to '/'
    else
      flash[:error] = "#{user.errors.full_messages.to_sentence}"
      render 'users/new'
    end
  end

  private

  def user_creation_params
    params.permit(:email, :password, :password_confirmation)
  end

  def registration_rate_limit_key
    "registration:#{request.remote_ip}"
  end

end
