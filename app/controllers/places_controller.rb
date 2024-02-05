class PlacesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :catch_not_found
  before_action :authenticate_user!
  before_action :set_place, only: %i[show edit update destroy]
  before_action :set_user_cities, only: %i[index create new edit update]
  before_action :set_country_and_city, only: %i[index edit new show]

  # GET /places or /places.json
  def index
    @q = Place.where(city: @city).ransack(params[:q])
    @pagy, @places = pagy(@q.result(distinct: true).order(created_at: :desc), items: 6)
  end

  # GET /places/1 or /places/1.json
  def show
    @place = Place.find(params[:id]) # Find the place
    @city = @place.city # Get the city associated with the place
    @country = @city.countries.first # Get the first country associated with the city
    @places = Place.where(city: @city) # Get all places within the same city
  end

  # GET /places/new
  def new
    @place = Place.new
    if params[:city_id].present?
      @city = City.find(params[:city_id])
      @country = @city.countries.first # Assuming you want the first country associated with the city
    else
      @country = Country.first
      @city = @country.cities.first 
    end
    @place.city = @city
  end

  # GET /places/1/edit
  def edit
  end

  # POST /places or /places.json
  def create
    @place = Place.new(place_params)
    user_city_ids = @user_cities.map(&:id)

    if user_city_ids.include?(@place.city_id)
      # Set @city based on the city_id of the new place
      @city = City.find(@place.city_id)
      # Set @country based on the first country associated with the city
      @country = @city.countries.first

      respond_to do |format|
        if @place.save
          format.html do
            redirect_to country_city_places_url(@country, @city), notice: 'Place was successfully created.'
          end
          format.json { render :show, status: :created, location: @place }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @place.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to new_place_path, alert: 'City is not valid or not accessible.' }
        format.json { render json: { error: 'City is not valid or not accessible' }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /places/1 or /places/1.json
  def update
    respond_to do |format|
      if @place.update(place_params)
        @city = @place.city
        @country = @city.countries.first

        format.html { redirect_to country_city_places_url(@country, @city), notice: 'Place was successfully updated.' }
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
      format.html { redirect_to country_city_places_url(@country, @city), notice: 'Place was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_place
    @place = Place.find(params[:id])
    @city = @place.city
    @country = @city.countries.first
  end

  # Only allow a list of trusted parameters through.
  def place_params
    params.require(:place).permit(:name, :category, :rating, :comments, :city_id)
  end

  def set_user_cities
    user_countries = current_user.countries
    @user_cities = user_countries.map(&:cities).flatten.uniq
  end

  def set_country_and_city
    @country = Country.find(params[:country_id])
    @city = @country.cities.find(params[:city_id])
  end

  def catch_not_found(e)
    Rails.logger.debug('We had a not found exception.')
    flash.alert = e.to_s
    redirect_to places_path
  end
end
