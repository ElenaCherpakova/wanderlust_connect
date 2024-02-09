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
  describe 'POST countries with valid params' do
    it 'creates a new country and redirect to countries' do
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
  end
  describe 'POST countries with invalid params' do
    it 'does not create a new country entry and render  the new template' do
      sign_in @current_user
      country_attributes = FactoryBot.attributes_for(:country, name: nil)

      expect do
        post countries_path, params: { country: country_attributes }
      end.not_to change(Country, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:new)
    end
  end

  describe 'PUT country with valid data' do
    it 'updates a country entry' do
      sign_in @current_user
      country = FactoryBot.create(:country, name: 'Unique Country Name')

      put country_path(country), params: { country: { name: 'Change Country' } }
      country.reload
      expect(country.name).to eq('Change Country')
      expect(response).to redirect_to(country_path(country))
    end
  end
  describe 'PUT country with invalid data' do
    it 'do not update country entry' do
      sign_in @current_user
      country = FactoryBot.create(:country, name: 'Unique Country Name')

      put country_path(country), params: { country: { name: 'a234' } }
      country.reload
      expect(country.name).not_to eq('a234')
      expect(response).to render_template(:edit)
    end
  end

  describe 'DELETE country record' do
    it 'delete country record' do
      sign_in @current_user
      country = FactoryBot.create(:country)
      expect do
        delete country_path(country)
      end.to change(Country, :count).by(-1)

      expect(Country.exists?(country.id)).to be false
      expect(response).to redirect_to countries_url
    end
  end
end
