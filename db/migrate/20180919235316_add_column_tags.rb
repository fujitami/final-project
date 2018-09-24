class AddColumnTags < ActiveRecord::Migration[5.0]
  def change
    add_column :tags, :color, :text
  end
end
