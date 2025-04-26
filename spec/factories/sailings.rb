FactoryBot.define do
  factory :sailing do
    origin_port { association :port }
    destination_port { association :port }
    departure_date { Date.today }
    arrival_date { Date.today + 5.days }
    days { 5 }
    cost_in_eur { 500.00 }
    sailing_rate { association :sailing_rate }
  end
end