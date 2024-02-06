require 'faker'

FactoryBot.define do
  factory :place do |f|
    f.name { Faker::Historical.place }
    f.category { Faker::Lorem.word }
    f.rating { Faker::Number.between(from: 1, to: 5) }
    f.comments { Faker::ChuckNorris.fact }
    association :city
  end
end
