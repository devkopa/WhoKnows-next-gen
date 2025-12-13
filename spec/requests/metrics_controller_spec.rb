require "rails_helper"

RSpec.describe MetricsController, type: :request do
  describe "GET /metrics" do
    let(:registry) { instance_double(Prometheus::Client::Registry) }

    let(:scalar_metric) do
      double(
        name: :http_requests_total,
        docstring: "Total HTTP requests",
        type: :counter,
        values: {
          { method: "GET", path: "/" } => 5,
          {} => 2
        }
      )
    end

    let(:histogram_metric) do
      double(
        name: :request_duration_seconds,
        docstring: "Request duration",
        type: :histogram,
        values: {
          { service: "api" } => {
            "0.5" => 1,
            "1.0" => 3,
            "count" => 3,
            "sum" => 2.0
          }
        }
      )
    end

    before do
      allow(Prometheus::Client).to receive(:registry).and_return(registry)
      allow(registry).to receive(:metrics).and_return([ scalar_metric, histogram_metric ])

      allow(User).to receive(:count).and_return(7)
      allow(USER_REGISTRATIONS).to receive(:respond_to?).and_return(true)
      allow(USER_REGISTRATIONS).to receive(:set).with(7)
    end

    it "returns metrics in Prometheus text format" do
      get "/metrics"

      expect(response).to have_http_status(:ok)
      expect(response.headers.fetch("Content-Type")).to include("text/plain")

      lines = response.body.split("\n")

      expect(lines).to include(
        "# HELP http_requests_total Total HTTP requests",
        "# TYPE http_requests_total counter",
        "http_requests_total{method=\"GET\",path=\"/\"} 5",
        "http_requests_total 2",
        "# HELP request_duration_seconds Request duration",
        "# TYPE request_duration_seconds histogram",
        "request_duration_seconds_bucket{service=\"api\",le=\"0.5\"} 1",
        "request_duration_seconds_bucket{service=\"api\",le=\"1.0\"} 3",
        "request_duration_seconds_count{service=\"api\"} 3",
        "request_duration_seconds_sum{service=\"api\"} 2.0"
      )
    end
  end

  describe "#update_user_registration_gauge" do
    it "logs a warning when the gauge update fails" do
      controller = described_class.new

      allow(USER_REGISTRATIONS).to receive(:respond_to?).and_return(true)
      allow(USER_REGISTRATIONS).to receive(:set).and_raise(StandardError, "boom")

      logger = instance_double(Logger)
      allow(Rails).to receive(:logger).and_return(logger)

      expect(logger).to receive(:warn).with("Could not update user_registrations_total: boom")

      controller.send(:update_user_registration_gauge)
    end
  end
end