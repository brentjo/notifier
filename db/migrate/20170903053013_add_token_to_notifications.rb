class AddTokenToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :token, :string
    add_index :notifications, :token, unique: true
  end
end
