require 'rails_helper'

RSpec.describe 'Countries', type: :request do
  before(:all) { @current_user = FactoryBot.create(:user) }

  after(:all) do
    sign_out @current_user
    @current_user.destroy
  end
  describe 'GET countries path' do
    it 'render the coutnry index page if user logged in successfully' do
      sign_in @current_user
      get countries_path
      expect(response).to be_successful
      expect(response).to render_template(:index)
    end
  end
  describe 'GET countries/:id' do
    it 'render the show page for country' do
      sign_in @current_user
      country = FactoryBot.create(:country)
      get country_path(country)
      expect(response).to be_successful
      expect(response).to render_template('countries/show')
    end
  end

  describe 'GET countries/new' do
    it 'render the new country form' do
      sign_in @current_user
      get new_country_path
      expect(response).to be_successful
      expect(response).to render_template('countries/new')
    end
  end
  describe 'POST countries' do
    it 'creates a new country with valid parameters and redirect to countries' do
      sign_in @current_user
      country_attributes = FactoryBot.attributes_for(:country)

      expect do
        post countries_path, params: { country: country_attributes }
      end.to change(Country, :count).by(1)

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(countries_url)
      follow_redirect!

      expect(response).to be_successful
      expect(response.body).to include('Country was successfully created.')
    end

    it 'does not create a new country if it already exists for the current user' do
      sign_in @current_user
      existing_country = FactoryBot.create(:country, name: 'Existing Country')
      @current_user.countries << existing_country
      country_attributes = FactoryBot.attributes_for(:country, name: 'Existing Country')
      expect do
        post countries_path, params: { country: country_attributes }
      end.not_to change(Country, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      # expect(response).to redirect_to(new_country_path)
      # follow_redirect!

      expect(response.body).to include('A country with the same name already exists in your list.')
    end

    it 'does not create a new country with invalid parameters' do
      sign_in @current_user
      country_attributes = FactoryBot.attributes_for(:country)
      country_attributes.delete(:name)

      expect do
        post countries_path, params: country_attributes
      end.not_to change(Country, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:new)
      expect(flash[:alert]).to be_present
    end
  end
  # describe 'PUT countries' do
  #   it 'update a country with valid parameters' do
  #     sign_in @current_user
  #     country_attributes = FactoryBot.attributes_for(:country)

  #     expect do
  #       post countries_path, params: { country: country_attributes }
  #     end.not_to change(Country, :count)

  #     expect(response).to have_http_status(:redirect)
  #     expect(response).to redirect_to(countries_url)
  #     follow_redirect!

  #     expect(response).to be_successful
  #     expect(response.body).to include('Country was successfully created.')
  #   end
  # end
end
