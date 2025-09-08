class CreateWorkouts < ActiveRecord::Migration[8.0]
  def change
    create_table :workouts do |t|
      t.date :date, null: false
      t.string :title
      t.text :content, null: false
      t.string :tags
      t.boolean :is_fallback, null: false, default: false

      t.timestamps
    end

    add_index :workouts, :date, unique: true
  end
end
