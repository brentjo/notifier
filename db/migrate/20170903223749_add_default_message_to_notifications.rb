class AddDefaultMessageToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :default_message, :string
  end
end
