require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "user has email downcased and stripped before downcase" do
    user = User.create!(email: " USER@exaMPLe.com \n", password: default_development_password)
    assert_equal user.email, "user@example.com"
  end

  test "notifications must have user enforced at DB level" do
    notification = Notification.new(email: "1111111111@vtext.com")
    assert_raises(ActiveRecord::NotNullViolation) do
      notification.save(validate: false)
    end
  end

  test "notifications are destroyed along with user" do
    user = create_user!
    notification = user.notifications.create!(email: "1111111111@vtext.com")
    refute notification.destroyed?
    user.destroy
    assert notification.destroyed?
  end

end
