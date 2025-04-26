class ExchangeRate < ApplicationRecord
  validates :date, :rates, presence: true
  validates :date, uniqueness: true
end

# == Schema Information
#
# Table name: exchange_rates
#
#  id    :integer          not null, primary key
#  date  :date             not null
#  rates :jsonb            not null
#
# Indexes
#
#  index_exchange_rates_on_date  (date) UNIQUE
#
