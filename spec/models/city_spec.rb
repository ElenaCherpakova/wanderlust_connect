require 'rails_helper'

RSpec.describe City, type: :model do
  before(:all) do
    @current_user = FactoryBot.create(:user)
    @country = FactoryBot.create(:country)
    @city = FactoryBot.create(:city)
  end

  after(:all) do
    @current_user.destroy
    @country.destroy
    @city.destroy
  end

  describe 'city validations' do
    it 'is not valid without name' do
      expect do
        FactoryBot.create(:city, name: nil)
      end.to raise_error(ActiveRecord::RecordInvalid, /Name can't be blank/)
    end

    it 'is not valid with a name shorter than 3 characters' do
      expect do
        FactoryBot.create(:country, name: 'Ab')
      end.to raise_error(ActiveRecord::RecordInvalid, /Name is too short/)
    end

    it 'is not valid with duplicate name within the same country' do
      FactoryBot.create(:city, name: 'Existing City', countries: [@country])
      begin
        FactoryBot.create(:city, name: 'Existing City', countries: [@country])
      rescue ActiveRecord::RecordInvalid => e
        expect(e.message).to match('A city with the same name already exists in this country.')
      end
    end
  end

  describe 'associations' do
    it 'has and belongs to many users' do
      association = described_class.reflect_on_association(:countries)
      expect(association).not_to be_nil
      expect(association.macro).to eq(:has_and_belongs_to_many)
    end
    it 'has many places' do
      association = described_class.reflect_on_association(:places)
      expect(association).not_to be_nil
      expect(association.macro).to eq(:has_many)
    end
  end
end
