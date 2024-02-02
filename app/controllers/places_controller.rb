class PlacesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :catch_not_found
  before_action :authenticate_user!
  before_action :set_place, only: %i[show edit update destroy]
  before_action :set_user_cities, only: %i[index create new edit update]

  # GET /places or /places.json
  def index
    user_city_ids = @user_cities.map(&:id)
    @places = Place.where(city_id: user_city_ids)
  end

  # GET /places/1 or /places/1.json
  def show
  end

  # GET /places/new
  def new
    @place = Place.new
    @place.city = City.find(params[:city_id]) if params[:city_id].present?
  end

  # GET /places/1/edit
  def edit
  end

  # POST /places or /places.json
  def create
    @place = Place.new(place_params)
    user_city_ids = @user_cities.map(&:id)
    unless user_city_ids.include?(@place.city_id)
      respond_to do |format|
        format.html { redirect_to new_place_path, alert: 'City is not valid or not accessible.' }
        format.json { render json: { error: 'City is not valid or not accessible' }, status: :unprocessable_entity }
        return
      end
    end

    respond_to do |format|
      if @place.save
        format.html { redirect_to place_url(@place), notice: 'Place was successfully created.' }
        format.json { render :show, status: :created, location: @place }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /places/1 or /places/1.json
  def update
    respond_to do |format|
      if @place.update(place_params)
        format.html { redirect_to place_url(@place), notice: 'Place was successfully updated.' }
        format.json { render :show, status: :ok, location: @place }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /places/1 or /places/1.json
  def destroy
    @place.destroy!

    respond_to do |format|
      format.html { redirect_to places_url, notice: 'Place was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_place
    @place = Place.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def place_params
    params.require(:place).permit(:name, :category, :rating, :comments, :city_id)
  end

  def set_user_cities
    user_countries = current_user.countries
    @user_cities = user_countries.map(&:cities).flatten.uniq
  end

  def catch_not_found(e)
    Rails.logger.debug('We had a not found exception.')
    flash.alert = e.to_s
    redirect_to places_path
  end
end
