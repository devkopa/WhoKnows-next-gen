class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :show, :ready, :live ]

  # GET /health - Basic health check
  def show
    render json: {
      status: "ok",
      timestamp: Time.current.iso8601,
      version: Rails.application.config.version || "1.0.0"
    }
  end

  # GET /health/ready - Readiness probe (checks dependencies)
  def ready
    checks = {
      database: check_database
    }

    all_ready = checks.values.all? { |v| v[:status] == "ok" || v[:status] == "skipped" }

    status_code = all_ready ? :ok : :service_unavailable

    render json: {
      status: all_ready ? "ready" : "not_ready",
      timestamp: Time.current.iso8601,
      checks: checks
    }, status: status_code
  end

  # GET /health/live - Liveness probe (checks if app is alive)
  def live
    render json: {
      status: "alive",
      timestamp: Time.current.iso8601,
      uptime: uptime_seconds
    }
  end

  # GET /health/metrics - Application metrics summary
  def metrics_summary
    render json: {
      status: "ok",
      timestamp: Time.current.iso8601,
      metrics: {
        users: {
          total: User.count,
          recent_24h: User.where("created_at > ?", 24.hours.ago).count
        },
        searches: {
          total: SearchLog.count,
          recent_24h: SearchLog.where("created_at > ?", 24.hours.ago).count
        },
        weather_searches: {
          total: WeatherSearch.count,
          recent_24h: WeatherSearch.where("created_at > ?", 24.hours.ago).count
        },
        pages: {
          total: Page.count
        }
      }
    }
  rescue => e
    render json: {
      status: "error",
      message: e.message,
      timestamp: Time.current.iso8601
    }, status: :internal_server_error
  end

  private

  def check_database
    ActiveRecord::Base.connection.execute("SELECT 1")
    { status: "ok", message: "Database connection successful" }
  rescue => e
    { status: "error", message: "Database connection failed: #{e.message}" }
  end

  def uptime_seconds
    # Calculate uptime based on when Rails was initialized
    Time.current - Rails.application.config.boot_time
  rescue
    0
  end
end
