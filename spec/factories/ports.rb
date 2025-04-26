FactoryBot.define do
  factory :port do
    sequence(:code) { |n| "PORT#{n}" }
  end
end