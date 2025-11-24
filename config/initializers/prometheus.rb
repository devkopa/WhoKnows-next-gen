require 'prometheus/client'

# Create a default registry
prometheus = Prometheus::Client.registry

# HTTP request metrics
HTTP_REQUESTS_TOTAL = prometheus.counter(
  :http_requests_total,
  docstring: 'Total HTTP requests',
  labels: [:method, :path, :status]
)

HTTP_REQUEST_DURATION = prometheus.histogram(
  :http_request_duration_seconds,
  docstring: 'HTTP request duration in seconds',
  labels: [:method, :path]
)

# User behavior metrics
USER_REGISTRATIONS = prometheus.counter(
  :user_registrations_total,
  docstring: 'Total user registrations'
)

USER_LOGINS = prometheus.counter(
  :user_logins_total,
  docstring: 'Total user login attempts',
  labels: [:status]
)

WEATHER_REQUESTS = prometheus.counter(
  :weather_requests_total,
  docstring: 'Total weather API requests'
)

SEARCH_REQUESTS = prometheus.counter(
  :search_requests_total,
  docstring: 'Total search requests'
)

PASSWORD_CHANGES = prometheus.counter(
  :password_changes_total,
  docstring: 'Total password change attempts',
  labels: [:status]
)
