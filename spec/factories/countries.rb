require 'faker'

FactoryBot.define do
  factory :country do |f|
    f.name { Faker::Address.country }
  end
end
