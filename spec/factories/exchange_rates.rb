FactoryBot.define do
  factory :exchange_rate do
    date { Date.today }
    rates { { 'usd' => 1.1, 'jpy' => 149.93 } }
  end
end