module Notifier
  def self.redis
    @redis ||= Redis.new(:url => (ENV["REDIS_URL"] || 'redis://localhost:6379'),
                        :reconnect_attempts => 10,
                        :reconnect_delay => 1.5,
                        :reconnect_delay_max => 10.0)
  end
end
