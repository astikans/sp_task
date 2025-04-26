require 'rails_helper'

RSpec.describe Sailing, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:departure_date) }
    it { should validate_presence_of(:arrival_date) }
    it { should validate_presence_of(:days) }
    it { should validate_presence_of(:cost_in_eur) }
  end

  describe 'associations' do
    it { should belong_to(:origin_port).class_name('Port') }
    it { should belong_to(:destination_port).class_name('Port') }
    it { should belong_to(:sailing_rate) }
  end
end