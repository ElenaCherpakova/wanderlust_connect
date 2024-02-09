require 'rails_helper'

RSpec.describe Country, type: :model do
  before(:all) do
    @current_user = FactoryBot.create(:user)
  end

  after(:all) do
    @current_user.destroy
  end

  describe 'country validations' do
    it 'is not valid without name' do
      expect do
        FactoryBot.create(:country, name: nil)
      end.to raise_error(ActiveRecord::RecordInvalid, /Name can't be blank/)
    end

    it 'is not valid with a name shorter than 3 characters' do
      expect do
        FactoryBot.create(:country, name: 'Ab')
      end.to raise_error(ActiveRecord::RecordInvalid, /Name is too short/)
    end

    it 'is not valid with duplicate name' do
      FactoryBot.create(:country, name: 'Unique Country')
      country = FactoryBot.build(:country, name: 'Unique Country')
      expect(country).not_to be_valid
      expect(country.errors[:name]).to include('has already been taken')
    end
  end

  describe 'associations' do
    it 'creates a country associated with the current user' do
      country = FactoryBot.create(:country, name: 'Example Country')
      country.users << @current_user
      expect(country).to be_valid
      expect(country.users).to include(@current_user)
    end

    it 'has and belongs to many users' do
      association = described_class.reflect_on_association(:users)
      expect(association).not_to be_nil
      expect(association.macro).to eq(:has_and_belongs_to_many)
    end
  end
end
