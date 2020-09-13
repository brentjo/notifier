class DashboardController < ApplicationController
  def show
    render 'dashboard/show'
  end

  def error
    render plain: '404 Not found', status: 404
  end
end
