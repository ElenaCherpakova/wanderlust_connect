require 'rails_helper'

RSpec.describe Place, type: :model do
  describe 'creating' do
    before(:all) do
      @current_user = FactoryBot.create(:user)
      @country = FactoryBot.create(:country)
      @city = FactoryBot.create(:city)
      @country.cities << @city
      @current_user.countries << @country
    end

    after(:all) do
      @current_user.destroy
      @country.destroy
      @city.destroy
    end

    it 'is valid with a name, category, rating, comments, city, and country associated with the current user' do
      place = FactoryBot.create(:place, city: @city)
      expect(place).to be_valid
      expect(place.city).to eq(@city)
      expect(@country.cities).to include(place.city)
      expect(@current_user.countries).to include(@country)
    end

    it 'is not valid without a name' do
      expect do
        FactoryBot.create(:place, name: nil, city: @city)
      end.to raise_error(ActiveRecord::RecordInvalid, /Name can't be blank/)
    end

    it 'is not valid without a category' do
      expect do
        FactoryBot.create(:place, category: nil, city: @city)
      end.to raise_error(ActiveRecord::RecordInvalid, /Category can't be blank/)
    end

    it 'is not valid without a rating' do
      expect do
        FactoryBot.create(:place, rating: nil, city: @city)
      end.to raise_error(ActiveRecord::RecordInvalid, /Rating can't be blank/)
    end

    it 'is not valid without comments' do
      expect do
        FactoryBot.create(:place, comments: nil, city: @city)
      end.to raise_error(ActiveRecord::RecordInvalid, /Comments can't be blank/)
    end

    it 'is not valid without a city' do
      expect do
        FactoryBot.create(:place, city: nil)
      end.to raise_error(ActiveRecord::RecordInvalid, /City must exist/)
    end

    it 'is not valid with a duplicate name within the same city' do
      FactoryBot.create(:place, name: 'Existing Place', city: @city)
      expect do
        FactoryBot.create(:place, name: 'Existing Place', city: @city)
      end.to raise_error(ActiveRecord::RecordInvalid, /Name has already been taken/)
    end

    it 'is not valid without an existing city' do
      non_existing_city_id = 999
      expect do
        FactoryBot.create(:place, city_id: non_existing_city_id)
      end.to raise_error(ActiveRecord::RecordInvalid, /City must exist/)
    end
  end
  describe 'associations' do
    it 'belongs to a city' do
      association = described_class.reflect_on_association(:city)
      expect(association).not_to be_nil
      expect(association.macro).to eq(:belongs_to)
    end
  end
end
