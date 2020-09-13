module RateLimiter

  POLICIES = {
    sign_in: {
      max_attempts: 5,
      time_period: 1.hours
    },
    register: {
      max_attempts: 3,
      time_period: 2.hours
    },
    send_message: {
      max_attempts: 20,
      time_period: 1.hours
    }
  }

  def self.allowed?(policy, rate_limit_key)
    unless should_enforce_rate_limits?
      return true
    end
    unless POLICIES.key?(policy) && POLICIES[policy][:max_attempts] && POLICIES[policy][:time_period]
      raise("Unknown or invalid policy for rate limiting: #{policy}")
    end

    if Notifier.redis.exists(rate_limit_key)
      if Notifier.redis.incr(rate_limit_key) > POLICIES[policy][:max_attempts]
        return false
      end
    else
      Notifier.redis.set(rate_limit_key, 1, :ex => POLICIES[policy][:time_period])
    end

    return true
  end

  def self.should_enforce_rate_limits?
    Rails.env.production?
  end

end
