require 'test_helper'

class SendEmailNotificationJobTest < ActiveJob::TestCase
  test "job is queued" do
    assert_enqueued_jobs 0
    job = SendEmailNotificationJob.perform_later("user@example.com", "Hello world!")
    assert_enqueued_jobs 1
  end
end
