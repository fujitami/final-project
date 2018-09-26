class RenamePlayerColumnToAlbums < ActiveRecord::Migration[5.0]
  def change
    rename_column :albums, :player, :spotify_id
  end
end
