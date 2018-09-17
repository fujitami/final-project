class AddNameToArtists < ActiveRecord::Migration[5.0]
  def change
    add_index :artists, :name, length: 50
  end
end
