require 'net/http'
require 'json'

module StatusPage

  class JSONFetch
    def self.fetch(url, method="GET")
      url = URI.parse(url)

      if(method == "GET")
        req = Net::HTTP::Get.new(url.to_s)
      else
        req = Net::HTTP::POST.new(url.to_s)
      end

      sh = { use_ssl: false }
      sh[:use_ssl] = true if url.scheme == "https"

      res = Net::HTTP.start(url.host, url.port, sh) { |http| http.request(req) }

      return JSON.load(res.body)
    end
  end

end
