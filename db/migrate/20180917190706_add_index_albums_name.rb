class AddIndexAlbumsName < ActiveRecord::Migration[5.0]
  def change
    add_index :albums, :name, length: 100
  end
end
