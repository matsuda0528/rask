class CreateTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks do |t|
      t.text :content, null: false
      t.integer :creator_id
      t.datetime :due_at
      t.integer :assigner_id
      t.text :description
      t.references :project, foreign_key: true, on_delete: :cascade
      t.references :serial_number
      t.timestamps
    end

    add_foreign_key :tasks, :projects, on_delete: :cascade
    add_foreign_key :tasks, :users, column: :creator_id, on_delete: :cascade
    add_foreign_key :tasks, :users, column: :assigner_id, on_delete: :cascade
  end
end
