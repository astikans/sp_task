class CreatePorts < ActiveRecord::Migration[8.0]
  def change
    create_table :ports do |t|
      t.string :code, null: false

      t.timestamps
    end

    add_index :ports, :code, unique: true
  end
end
