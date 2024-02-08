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

  # GET /countries/1/edit
  def create
    @country = Country.new(country_params)
    # Check if the country name is blank or too short, or if it already exists.
    # These checks are now handled by model validations, so this part can be simplified.

    if current_user.countries.where('lower(name) = ?', @country.name.downcase).exists?
      @country.errors.add(:name, 'already exists in your list')
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @country.errors, status: :unprocessable_entity }
      end
    elsif @country.save
      current_user.countries << @country
      respond_to do |format|
        format.html { redirect_to countries_url, notice: 'Country was successfully created.' }
        format.json { render :show, status: :created, location: @country }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @country.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /countries/1 or /countries/1.json
  def update
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
    @country.destroy!

    respond_to do |format|
      format.html { redirect_to countries_url, notice: 'Country was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_country
    @country = current_user.countries.find_by(params[:id])
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
