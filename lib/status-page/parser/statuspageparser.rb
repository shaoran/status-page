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

      desc = status["description"]

      ret = {
        page_id:   page_id,
        page_name: page_name,
        timestamp: updated.to_i,
      }

      if desc == "All Systems Operational"
        s = "good"
      elsif desc == "Partial System Outage"
        s = "bad"
      elsif desc == "Major Service Outage"
        s = "down"
      else
        s = "unkown"
      end

      ret["status"] = s

      ret
    end
  end

end
