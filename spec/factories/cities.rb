require 'faker'

FactoryBot.define do
  factory :city do |f|
    f.name { Faker::Address.city }
  end
end
