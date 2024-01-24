class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @countries = current_user.countries
  end
end