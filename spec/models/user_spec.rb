require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'creating a user' do
    before do
      @user = FactoryBot.create(:user)
    end

    after(:each) do
      @user.destroy
    end

    it 'is not valid without an email' do
      @user.email = nil
      expect(@user).not_to be_valid
    end

    it 'is not valid without a password' do
      @user.password = nil
      expect(@user).not_to be_valid
    end

    it 'is not valid with a non-unique email' do
      expect do
        FactoryBot.create(:user,
                          email: @user.email)
      end.to raise_error(ActiveRecord::RecordInvalid, /Email has already been taken/)
    end
  end
end
