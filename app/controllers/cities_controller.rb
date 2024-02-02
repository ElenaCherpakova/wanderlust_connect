class CitiesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :catch_not_found
  before_action :authenticate_user!
  before_action :set_city, only: %i[show edit update destroy]

  def index
    # First, check if a country_id is provided in the params
    country_id = params[:country_id] || session[:last_viewed_country_id]
  
    if country_id.present?
      @country = current_user.countries.find_by(id: country_id)
  
      if @country
        @cities = @country.cities
      else
        flash[:alert] = 'Selected country does not exist or does not belong to you.'
        redirect_to cities_path
      end
    else
      @cities = []
    end
  end

  # GET /cities/1 or /cities/1.json
  def show
    if @city.countries.any?
      session[:last_viewed_country_id] = @city.countries.first.id
    end
  end

  # GET /cities/new
  def new
    @city = City.new
    @user_countries = current_user.countries
  end

  # GET /cities/1/edit
  def edit
    @user_countries = current_user.countries
  end

  # POST /cities or /cities.json
  def create
    @city = City.new(city_params)
    selected_country_id = params[:city][:country_id]
    selected_country = current_user.countries.find_by(id: selected_country_id)

    if selected_country.nil?
      flash[:alert] = 'Please select a country first'
      redirect_to new_city_path and return
    end

    existing_city = selected_country.cities.find_by(name: @city.name)

    if existing_city
      flash[:alert] = 'A city with the same name already exists in this country.'
      redirect_to new_city_path(city_id: @city.id) and return
    end

    @city.countries << selected_country

    respond_to do |format|
      if @city.save
        format.html { redirect_to city_url(@city), notice: 'City was successfully created.' }
        format.json { render :index, status: :created, location: @city }
      else
        @user_countries = current_user.countries
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @city.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cities/1 or /cities/1.json
  def update
    respond_to do |format|
      if @city.update(city_params)
        format.html { redirect_to city_url(@city), notice: 'City was successfully updated.' }
        format.json { render :show, status: :ok, location: @city }
      else
        @user_countries = current_user.countries
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @city.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cities/1 or /cities/1.json
  def destroy
    @city.destroy!

    respond_to do |format|
      format.html { redirect_to cities_url, notice: 'City was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_city
    @city = City.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def city_params
    params.require(:city).permit(:name, country_ids: [])
  end

  def catch_not_found(e)
    Rails.logger.debug('We had a not found exception.')
    flash.alert = e.to_s
    redirect_to countries_path
  end
end
