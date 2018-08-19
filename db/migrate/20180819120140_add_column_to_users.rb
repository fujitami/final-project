class AddColumnToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :name, :text, null: false, unique: true
    add_column :users, :icon, :string
  end
end
