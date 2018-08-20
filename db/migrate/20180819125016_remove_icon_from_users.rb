class RemoveIconFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :icon, :string
  end
end
