class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    order = params[:order] == 'desc' ? 'desc' : 'asc'

    @countries = current_user.countries.order(name: order)
  end
end