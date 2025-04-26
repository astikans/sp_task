FactoryBot.define do
  factory :sailing_rate do
    sequence(:code) { |n| "RATE#{n}" }
    rate { 100.00 }
    rate_currency { "USD" }
  end
end