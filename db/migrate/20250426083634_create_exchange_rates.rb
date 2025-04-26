class CreateExchangeRates < ActiveRecord::Migration[8.0]
  def change
    create_table :exchange_rates do |t|
      t.date :date, null: false
      t.jsonb :rates, null: false
    end

    add_index :exchange_rates, :date, unique: true
  end
end
