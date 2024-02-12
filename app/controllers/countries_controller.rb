class CountriesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :catch_not_found
  before_action :authenticate_user!

  before_action :set_country, only: %i[show edit update destroy]
  # GET /countries or /countries.json
  def index
    @pagy, @countries = pagy(current_user.countries.order(:name), items: 6)
  end

  # GET /countries/1 or /countries/1.json
  def show
    @country = Country.find(params[:id])
  end

  # GET /countries/new
  def new
    @country = Country.new
  end

  # POST /countries
  def create
    @country = current_user.countries.create(country_params) # Associate the country with the current_user

    respond_to do |format|
      if @country.save
        format.html { redirect_to countries_url, notice: 'Country was successfully created.' }
        format.json { render :show, status: :created, location: @country }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @country.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /countries/1 or /countries/1.json
  def update
    @country = Country.find(params[:id])

    existing_country = current_user.countries.find_by(name: country_params[:name])
    if existing_country && existing_country != @country
      flash[:alert] = 'A country with the same name already exists in your list.'
      redirect_to edit_country_path(@country)
    else
      respond_to do |format|
        if @country.update(country_params)
          format.html { redirect_to country_url(@country), notice: 'Country was successfully updated.' }
          format.json { render :show, status: :ok, location: @countries }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @country.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /countries/1 or /countries/1.json
  def destroy
    @country = Country.find_by(id: params[:id])

    @country.destroy!
    respond_to do |format|
      format.html { redirect_to countries_url, notice: 'Country was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_country
    @country = current_user.countries.find_by(id: params[:id])
  end

  # Only allow a list of trusted parameters through.
  def country_params
    params.require(:country).permit(:name)
  end

  def catch_not_found(e)
    Rails.logger.debug('We had a not found exception.')
    flash.alert = e.to_s
    redirect_to countries_path
  end
end
