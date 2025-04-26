class CreateSailings < ActiveRecord::Migration[8.0]
  def change
    create_table :sailings do |t|
      t.references :origin_port, null: false, foreign_key: { to_table: :ports }, index: true
      t.references :destination_port, null: false, foreign_key: { to_table: :ports }, index: true
      t.date :departure_date, null: false
      t.date :arrival_date, null: false
      t.integer :days, null: false
      t.decimal :cost_in_eur, precision: 10, scale: 2, null: false

      t.references :sailing_rate, null: false, foreign_key: { to_table: :sailing_rates }, index: true

      t.timestamps
    end

  end
end
