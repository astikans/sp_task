require 'rails_helper'

RSpec.describe Port, type: :model do
  describe 'validations' do
    subject { Port.new(code: 'NLRTM') }

    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code) }
  end

  describe 'associations' do
    it { should have_many(:origin_sailings).class_name('Sailing').with_foreign_key(:origin_port_id).dependent(:destroy) }
    it { should have_many(:destination_sailings).class_name('Sailing').with_foreign_key(:destination_port_id).dependent(:destroy) }
  end
end