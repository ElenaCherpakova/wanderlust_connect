class DashboardController < ApplicationController
  before_action :authenticate_user!
  def index
    @q = current_user.countries.ransack(params[:q])
    order_by_name = params[:order] == 'desc' ? 'name DESC' : 'name ASC'
    order_by_created_at = params[:order] == 'desc' ? 'created_at DESC' : 'created_at ASC'

    @pagy, @countries = if params[:order_by] == 'name'
                          pagy(@q.result(distinct: true).order(order_by_name), items: 6)
                        else
                          pagy(@q.result(distinct: true).order(order_by_created_at), items: 6)
                        end
  end
end
