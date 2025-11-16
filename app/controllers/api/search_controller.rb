module Api
  class SearchController < ApplicationController
    # Brug simpel URL, da route helpers ikke altid virker i API namespace
    BASE_PAGE_URL = "/pages/"

    def index
      query = params[:q].to_s.strip

      @results = if query.present?
        # Split query på mellemrum for at understøtte flere søgeord
        terms = query.split

        # Byg en SQL-condition for hvert ord, både title og content
        conditions = terms.map do |term|
          "(title ILIKE :t OR content ILIKE :t)"
        end.join(" AND ")

        # Parametre til query
        values = { t: "%#{terms.join('%')}%" }

        # Søg i pages-tabellen
        Page.where(conditions, values)
            .map do |page|
          {
            title: page.title,
            url: "#{BASE_PAGE_URL}#{page.id}",
            content: page.content.truncate(150)
          }
        end
      else
        []
      end

      respond_to do |format|
        format.html { render template: "search/index" }
        format.json { render json: @results }
      end
    end
  end
end