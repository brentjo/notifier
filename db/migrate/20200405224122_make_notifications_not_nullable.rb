class MakeNotificationsNotNullable < ActiveRecord::Migration[6.0]
  def change
    change_column :notifications, :user_id, :bigint, null: false
    change_column :notifications, :token, :string, null: false
  end
end
