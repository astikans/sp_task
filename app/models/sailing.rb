class Sailing < ApplicationRecord
  validates :departure_date, :arrival_date, :days, :cost_in_eur, presence: true

  belongs_to :origin_port, class_name: "Port"
  belongs_to :destination_port, class_name: "Port"
  belongs_to :sailing_rate
end

# == Schema Information
#
# Table name: sailings
#
#  id                  :integer          not null, primary key
#  origin_port_id      :integer          not null
#  destination_port_id :integer          not null
#  departure_date      :date             not null
#  arrival_date        :date             not null
#  days                :integer          not null
#  cost_in_eur         :decimal(10, 2)   not null
#  sailing_rate_id     :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_sailings_on_destination_port_id  (destination_port_id)
#  index_sailings_on_origin_port_id       (origin_port_id)
#  index_sailings_on_sailing_rate_id      (sailing_rate_id)
#
