class AddColumnBanToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :ban, :string
  end
end
