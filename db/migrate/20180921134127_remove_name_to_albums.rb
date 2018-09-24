class RemoveNameToAlbums < ActiveRecord::Migration[5.0]
  def change
    remove_column :albums, :name, :string
  end
end
