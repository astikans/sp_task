require 'rails_helper'

RSpec.describe ExchangeRate, type: :model do
  describe 'validations' do
    subject { ExchangeRate.new(date: Date.new(2025, 1, 1), rates: { 'USD' => 1.0, 'EUR' => 0.85 }) }

    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:rates) }
    it { should validate_uniqueness_of(:date) }
  end

  describe 'database columns' do
    it { should have_db_column(:date).of_type(:date).with_options(null: false) }
    it { should have_db_column(:rates).of_type(:jsonb).with_options(null: false) }
    it { should have_db_index(:date).unique(true) }
  end
end