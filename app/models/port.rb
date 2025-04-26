class Port < ApplicationRecord
  validates :code, presence: true
  validates :code, uniqueness: true

  has_many :origin_sailings, class_name: "Sailing", foreign_key: :origin_port_id, dependent: :destroy
  has_many :destination_sailings, class_name: "Sailing", foreign_key: :destination_port_id, dependent: :destroy
end

# == Schema Information
#
# Table name: ports
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_ports_on_code  (code) UNIQUE
#
