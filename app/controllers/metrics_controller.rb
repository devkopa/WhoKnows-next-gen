class MetricsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :allow_browser, raise: false

  def index
    # Update user registrations gauge dynamically
    begin
      USER_REGISTRATIONS.set(User.count) if USER_REGISTRATIONS.respond_to?(:set)
    rescue => e
      Rails.logger.warn("Could not update user_registrations_total: #{e.message}")
    end

    output = []

    Prometheus::Client.registry.metrics.each do |metric|
      output << "# HELP #{metric.name} #{metric.docstring}"
      output << "# TYPE #{metric.name} #{metric.type}"

      metric.values.each do |label_set, value|
        # Handle histogram buckets
        if metric.type == :histogram && value.is_a?(Hash)
          value.each do |bucket, count|
            if bucket == "sum"
              labels_str = label_set.empty? ? "" : "{#{label_set.map { |k, v| "#{k}=\"#{v}\"" }.join(',')}}"
              output << "#{metric.name}_sum#{labels_str} #{count}"
            elsif bucket == "count"
              labels_str = label_set.empty? ? "" : "{#{label_set.map { |k, v| "#{k}=\"#{v}\"" }.join(',')}}"
              output << "#{metric.name}_count#{labels_str} #{count}"
            else
              bucket_labels = label_set.merge(le: bucket)
              labels_str = "{#{bucket_labels.map { |k, v| "#{k}=\"#{v}\"" }.join(',')}}"
              output << "#{metric.name}_bucket#{labels_str} #{count}"
            end
          end
        else
          # Handle counters and gauges
          if label_set.empty?
            output << "#{metric.name} #{value}"
          else
            labels = label_set.map { |k, v| "#{k}=\"#{v}\"" }.join(",")
            output << "#{metric.name}{#{labels}} #{value}"
          end
        end
      end
      output << ""
    end

    render plain: output.join("\n"), content_type: "text/plain; version=0.0.4"
  end
end
