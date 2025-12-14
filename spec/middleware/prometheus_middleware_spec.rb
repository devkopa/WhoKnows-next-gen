require 'rails_helper'
require 'rack'
require_relative '../../app/middleware/prometheus_middleware'

RSpec.describe PrometheusMiddleware do
  let(:inner_app) do
    # Simple Rack app returning 200 and a body
    lambda { |_env| [ 200, { 'Content-Type' => 'text/plain' }, [ 'OK' ] ] }
  end

  let(:middleware) { described_class.new(inner_app) }

  let(:http_requests_total) { double('HTTP_REQUESTS_TOTAL') }
  let(:http_request_duration) { double('HTTP_REQUEST_DURATION') }

  before do
    # Stub global metrics constants if present; otherwise define them
    stub_const('HTTP_REQUESTS_TOTAL', http_requests_total)
    stub_const('HTTP_REQUEST_DURATION', http_request_duration)

    allow(http_requests_total).to receive(:increment)
    allow(http_request_duration).to receive(:observe)
  end

  def call(env_overrides = {})
    env = {
      'REQUEST_METHOD' => 'GET',
      'PATH_INFO' => '/users/123'
    }.merge(env_overrides)
    middleware.call(env)
  end

  it 'initializes with an app' do
    expect(middleware).to be_a(PrometheusMiddleware)
  end

  it 'bypasses instrumentation for /metrics path to avoid recursion' do
    status, headers, body = call('PATH_INFO' => '/metrics')

    expect(status).to eq(200)
    expect(headers['Content-Type']).to eq('text/plain')
    expect(body.each.to_a.join).to eq('OK')

    expect(http_requests_total).not_to have_received(:increment)
    expect(http_request_duration).not_to have_received(:observe)
  end

  it 'records request metrics for non-/metrics paths with normalized path' do
    status, _headers, _body = call('REQUEST_METHOD' => 'POST', 'PATH_INFO' => '/users/456/profile')

    expect(status).to eq(200)

    # Duration observed with method and normalized path labels
    expect(http_request_duration).to have_received(:observe) do |duration, labels:|
      expect(duration).to be_a(Numeric)
      expect(labels[:method]).to eq('POST')
      expect(labels[:path]).to eq('/users/:id/profile')
    end

    # Request count incremented with method, path, and status labels
    expect(http_requests_total).to have_received(:increment).with(
      labels: { method: 'POST', path: '/users/:id/profile', status: 200 }
    )
  end

  it 'normalizes numeric path segments to :id to avoid high cardinality' do
    call('PATH_INFO' => '/orders/987/items/654')

    expect(http_requests_total).to have_received(:increment).with(
      labels: { method: 'GET', path: '/orders/:id/items/:id', status: 200 }
    )
  end
end
