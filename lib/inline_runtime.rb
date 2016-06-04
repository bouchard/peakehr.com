module Rack
  # Adds a total runtime for this request wherever the magic tag is throughout the app.
  class InlineRuntime
    def initialize(app, name = nil)
      @app = app
    end

    def call(env)
      start_time = Time.now
      status, headers, body = @app.call(env)
      request_time = Time.now - start_time

      if headers['Content-Type'] && headers['Content-Type'].match('text/html')
        obody, body = body, []
        obody.each{ |b| body << b.gsub('<Rack::InlineRuntime>', "%0.4f" % request_time) }
      end

      [status, headers, body]
    end
  end
end
