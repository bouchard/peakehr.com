class EventSource
  @@redis = Redis.new
  class << self
    def publish(channel, message)
      @@redis.publish(channel, message.is_a?(String) ? message : message.to_json)
    end
  end
end