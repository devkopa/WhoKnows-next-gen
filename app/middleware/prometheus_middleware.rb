class PrometheusMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # Skip metrics endpoint to avoid recursion
    if env['PATH_INFO'] == '/metrics'
      return @app.call(env)
    end

    start_time = Time.now
    status, headers, response = @app.call(env)
    duration = Time.now - start_time

    method = env['REQUEST_METHOD']
    path = normalize_path(env['PATH_INFO'])

    # Track request count
    HTTP_REQUESTS_TOTAL.increment(labels: { method: method, path: path, status: status })

    # Track request duration
    HTTP_REQUEST_DURATION.observe(duration, labels: { method: method, path: path })

    [status, headers, response]
  end

  private

  def normalize_path(path)
    # Normalize paths with IDs to avoid high cardinality
    # /users/123 -> /users/:id
    path.gsub(/\/\d+/, '/:id')
  end
end
