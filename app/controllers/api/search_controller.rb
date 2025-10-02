module Api
  class SearchController < ApplicationController
    def index
      query = params[:q].to_s.downcase

      routes = Rails.application.routes.routes.map do |route|
        next unless route.verb.match?(/^GET$/)
        path = route.path.spec.to_s.gsub("(.:format)", "")
        { path: path, name: route.name.to_s }
      end.compact

      results = routes.select do |r|
        r[:path].downcase.include?(query) || r[:name].to_s.downcase.include?(query)
      end

      @results = results.map do |r|
        { title: r[:name].presence || r[:path], url: r[:path], content: "Page: #{r[:path]}" }
      end

      respond_to do |format|
        format.html { render template: "search/index" }   # 👈 peger på app/views/search/index.html.erb
        format.json { render json: @results }
      end
    end
  end
end