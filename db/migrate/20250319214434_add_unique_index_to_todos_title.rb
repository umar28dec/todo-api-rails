class AddUniqueIndexToTodosTitle < ActiveRecord::Migration[7.0]
  def change
    add_index :todos, :title, unique: true
  end
end