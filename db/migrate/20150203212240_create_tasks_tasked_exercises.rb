class CreateTasksTaskedExercises < ActiveRecord::Migration
  def change
    create_table :tasks_tasked_exercises do |t|
      t.string :url, null: false
      t.text :content, null: false
      t.boolean :has_recovery, null: false, default: false
      t.string :title
      t.text :free_response
      t.string :answer_id

      t.timestamps null: false
    end
  end
end
