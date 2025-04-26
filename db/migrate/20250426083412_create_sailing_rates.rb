class CreateSailingRates < ActiveRecord::Migration[8.0]
  def change
    create_table :sailing_rates do |t|
      t.string :code, null: false
      t.decimal :rate, precision: 10, scale: 2, null: false
      t.string :rate_currency, null: false

      t.timestamps
    end

    add_index :sailing_rates, :code, unique: true
  end
end
