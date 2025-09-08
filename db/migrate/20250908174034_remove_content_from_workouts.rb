class RemoveContentFromWorkouts < ActiveRecord::Migration[8.0]
  def change
    remove_column :workouts, :content, :text
  end
end
