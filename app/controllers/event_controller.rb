class EventController < ApplicationController
  include ActionController::Live
  before_action :setup_stream

  def index
    head :not_found and return
    response.headers['Content-Type'] = 'text/event-stream'
    @redis.subscribe('new_attachment', 'mobile_paired') do |on|
      on.message do |event, data|
        @sse.write(data, event: event)
      end
    end
  rescue IOError
    # Client disconnected.
  ensure
    @sse.close
  end

  private

  def setup_stream
    @sse = SSE.new(response.stream, retry: 300, event: 'default')
    @redis = Redis.new
  end

end
