class AddAttachmentIconToUsers < ActiveRecord::Migration[5.0]
  def self.up
    change_table :users do |t|
      t.attachment :icon
    end
  end

  def self.down
    remove_attachment :users, :icon
  end
end
