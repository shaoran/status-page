require "time"

module StatusPage

  class StatusPageParser
    def self.parse(response)

      return nil unless response.is_a? Hash

      page = response["page"]

      return nil if page.nil?

      page_id = page["id"]
      page_name = page["name"]

      begin
        updated = Time.parse(page["updated_at"])
      rescue
        return nil
      end

      status = response["status"]

      return nil if status.nil?

      indicator = status["indicator"]

      indicator = "up" if indicator == "none"

      ret = {
        page_id:   page_id,
        page_name: page_name,
        timestamp: updated.to_i,
        status: indicator
      }

      ret
    end
  end

end
