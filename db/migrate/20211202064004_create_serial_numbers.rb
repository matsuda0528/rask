class CreateSerialNumbers < ActiveRecord::Migration[6.1]
  def change
    create_table :serial_numbers do |t|
      t.references :task, foreign_key: true
      t.timestamps
    end
  end
end
