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
        @pagy, @cities = pagy(@country.cities.order(:name), items: 6)
      else
        flash[:alert] = 'Selected country does not exist or does not belong to you.'
        redirect_to countries_path
      end
    else
      @cities = []
    end
  end

  # GET /cities/1 or /cities/1.json
  def show
    # return unless @city.countries.any?

    # session[:last_viewed_country_id] = @city.countries.first.id
    # @city = City.find(params[:id])
    @country = @city.countries.first
  end

  # GET /cities/new
  def new
    @city = City.new
    @user_countries = current_user.countries
    @country = @user_countries.first
  end

  # GET /cities/1/edit
  def edit
    @user_countries = current_user.countries
  end

  # POST /cities or /cities.json
  def create
    @country = current_user.countries.find(params[:country_id])
    @city = @country.cities.build(city_params)

    selected_country_id = params[:city][:country_id]
    selected_country = current_user.countries.find_by(id: selected_country_id)

    if selected_country.nil?
      flash[:alert] = 'Please select a country first'
      redirect_to new_country_city_url(city_id: @city.id) and return
    end

    existing_city = selected_country.cities.find_by('LOWER(name) = ?', @city.name.downcase)

    if existing_city
      flash[:alert] = 'A city with the same name already exists in this country.'
      redirect_to new_country_city_path(selected_country, city_id: @city.id) and return
    end

    respond_to do |format|
      if @city.save
        @city.countries << selected_country
        format.html { redirect_to country_cities_path(selected_country), notice: 'City was successfully created.' }
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
    @city = City.find(params[:id])
    old_country = @city.countries

    selected_country_id = params[:city][:country_id]
    new_country = current_user.countries.find_by(id: selected_country_id)

    if new_country.nil?
      flash[:alert] = 'Please select a country first.'
      redirect_to edit_country_city_path and return
    end

    if new_country.cities.where.not(id: @city.id).where('lower(name) = ?', city_params[:name].downcase).exists?
      flash[:alert] = 'A city with the same name already exists in the selected country.'
      redirect_to edit_city_path(@city) and return
    end
    
    @user_countries = current_user.countries

    respond_to do |format|
      if @city.update(city_params)
        if old_country && old_country.id != new_country.id
          old_country.cities.delete(@city)
          new_country.cities << @city
        end
        format.html { redirect_to country_cities_url(new_country), notice: 'City was successfully updated.' }
        format.json { render :show, status: :ok, location: @city }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @city.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cities/1 or /cities/1.json
  def destroy
    @city.destroy!

    respond_to do |format|
      format.html { redirect_to country_cities_url, notice: 'City was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_city
    @country = current_user.countries.find(params[:country_id])
    @city = @country.cities.find(params[:id])
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
