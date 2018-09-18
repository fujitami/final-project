class CreateAlbums < ActiveRecord::Migration[5.0]
  def change
    create_table :albums do |t|
      t.text :name, null: false, foreign_key: true
      t.string :player, null: false
      t.timestamps
    end
  end
end
