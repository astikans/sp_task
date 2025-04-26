class SailingRate < ApplicationRecord
  validates :code, :rate, :rate_currency, presence: true
  validates :code, uniqueness: true

  has_many :sailings, foreign_key: :sailing_rate_id, dependent: :destroy

  def eur?
    rate_currency == "EUR"
  end
end

# == Schema Information
#
# Table name: sailing_rates
#
#  id            :integer          not null, primary key
#  code          :string           not null
#  rate          :decimal(10, 2)   not null
#  rate_currency :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_sailing_rates_on_code  (code) UNIQUE
#
