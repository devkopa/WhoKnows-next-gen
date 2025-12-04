class MetricsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :allow_browser, raise: false

  def index
    update_user_registration_gauge

    output = Prometheus::Client.registry.metrics.flat_map do |metric|
      format_metric(metric)
    end

    render plain: output.join("\n"), content_type: "text/plain; version=0.0.4"
  end

  private

  def update_user_registration_gauge
    USER_REGISTRATIONS.set(User.count) if USER_REGISTRATIONS.respond_to?(:set)
  rescue => e
    Rails.logger.warn("Could not update user_registrations_total: #{e.message}")
  end

  def format_metric(metric)
    header = [
      "# HELP #{metric.name} #{metric.docstring}",
      "# TYPE #{metric.name} #{metric.type}"
    ]

    body = metric.values.flat_map do |label_set, value|
      metric.type == :histogram ?
        format_histogram(metric, label_set, value) :
        format_scalar(metric, label_set, value)
    end

    header + body + [ "" ]
  end

  def format_label_set(label_set)
    return "" if label_set.empty?
    "{#{label_set.map { |k, v| "#{k}=\"#{v}\"" }.join(',')}}"
  end

  def format_scalar(metric, label_set, value)
    "#{metric.name}#{format_label_set(label_set)} #{value}"
  end

  def format_histogram(metric, label_set, value)
    value.map do |bucket, count|
      case bucket
      when "sum"
        "#{metric.name}_sum#{format_label_set(label_set)} #{count}"
      when "count"
        "#{metric.name}_count#{format_label_set(label_set)} #{count}"
      else
        merged = label_set.merge(le: bucket)
        "#{metric.name}_bucket#{format_label_set(merged)} #{count}"
      end
    end
  end
end
