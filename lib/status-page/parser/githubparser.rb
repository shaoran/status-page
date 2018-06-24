require "time"

module StatusPage

  # see https://status.github.com/api
  class GitHubParser
    def self.parse(response)

      # {"status":"good","last_updated":"2018-06-11T16:50:02Z"}

      return nil unless response.is_a? Hash

      status = response["status"]

      return nil if status.nil?

      begin
        updated = Time.parse(response["last_updated"])
      rescue
        return nil
      end

      status = "up" if status == "good"

      ret = {
        page_id:   "github",
        page_name: "github.com",
        timestamp: updated.to_i,
        status: status,
      }

      ret
    end
  end

end
