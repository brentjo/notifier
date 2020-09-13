class AddTotalCountToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :total_sent, :integer
    add_column :notifications, :last_sent, :datetime
  end
end
