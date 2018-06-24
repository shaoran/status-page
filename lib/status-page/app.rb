require "time"
require 'securerandom'
require 'byebug'

module StatusPage

  class App
    def initialize(config_base=nil)
      setup_model(config_base)
      setup_config(config_base)
    end

    def list_services
      @pageinfo.list
    end

    def pull
      results = @pageinfo.pageinfo.map do |id,config|

        begin
          json = StatusPage::JSONFetch.fetch(config["url"])
        rescue
          r = fetch_error(id, "Unable to fetch from API for", Time.new)
          next r
        end

        begin
          json = config["parser"].parse(json)
        rescue
          r = fetch_error(id, "Unable to parse response", Time.new)
          next r
        end

        json["service"] = id
        json["id"]      = SecureRandom.uuid
        json["error"] = false

        json
      end

      results.map do |json|
        Pages.new json
      end

    end

    def pull_and_store
      self.pull.map do |page|
        page.save!
        page
      end
    end

    def history(pages=nil)
      pages = Pages.all if pages.nil?

      pages.sort! do |p1,p2|
        ret = p1.service.downcase <=> p2.service.downcase
        next ret if ret != 0

        next -1 * (p1.timestamp <=> p2.timestamp)
      end

      puts "#{"Servive".ljust(15)} #{"Status".ljust(10)} #{"Time".ljust(30)} Comments"

      pages.each do |page|
        line = []
        line << page.service.ljust(15)
        line << translate_status(page.status).ljust(10)
        line << Time.at(page.timestamp).to_s.ljust(30)
        line << "Error: #{page.error_msg} @ #{Time.at(page.error_ts).to_s}" if page.error

        puts line.join(" ")
      end
    end


    def backup(path)
      begin
        Pages.backup(path)
      rescue
        return false
      end

      true
    end

    def restore(path)
      begin
        Pages.restore(path)
      rescue StatusPage::InvalidArchive
        STDERR.puts "`#{path}' is an invalid archive"
        return false
      rescue
        return false
      end

      true
    end

    def stats
      services = {}

      Pages.all.each do |page|
        services[page.service] = { pages: [], stats: {} } unless services.include?(page.service)

        services[page.service][:pages] << page
      end

      now = Time.now.to_i

      services.each do |service,ctn|
        # delete error fetch/parse error,
        # the timestamp is unknown
        ctn[:pages].delete_if do |page|
          page.error
        end

        ctn[:pages].sort! do |p1,p2|
          next -1 * (p1.timestamp <=> p2.timestamp)
        end

        # remove duplicates (by timestamp)
        ctn[:pages].uniq! do |page|
          page.timestamp
        end

        uptime = ctn[:pages][-1].timestamp
        now = Time.now.to_i

        ctn[:pages].each do |page|
          break unless [ "up", "minor" ].include?(page.status)

          uptime = page.timestamp
        end

        uptime = now - uptime
        uptime = 0 if uptime == 0

        services[service][:stats][:up] = humanize_time(uptime)

        # tracks the timestamp of down time, -1 when last
        # entry was an "up" entry
        last_ts = -1

        # accumulates the down time
        downtime = 0

        ctn[:pages].reverse.each do |page|
          is_up = ["up", "minor"].include?(page.status)
          next if is_up && last_ts == -1  #last entry was up/beginning with up

          if is_up
            delta = page.timestamp - last_ts
            last_ts = -1
            downtime += delta
            next
          end

          # current is down

          if last_ts != -1
            # last entry also a down, accumlate
            delta = page.timestamp - last_ts
            downtime += delta
          end

          last_ts = page.timestamp

        end #of ctn[:pages].reverse.each

        downtime += (now - last_ts) if last_ts != -1

        hdt = "-"
        hdt = humanize_time(downtime) if downtime > 0

        services[service][:stats][:down] = hdt

      end #of services each

      puts "#{"Service".ljust(15)} #{"Up Since".ljust(30)} #{"Down time".ljust(30)}"


      services.each do |service,ctn|
        line = []

        line << service.ljust(15)
        line << "#{ctn[:stats][:up]}".ljust(30)
        line << "#{ctn[:stats][:down]}".ljust(30)

        puts line.join(" ")
      end

    end


    protected
    def setup_model(config_base)
      bs = nil
      unless config_base.nil?
        bs = File.join(config_base, "db")
        Pages.db_base = bs
      end
      Pages.reload_cache
    end

    def setup_config(config_base)
      fn = nil
      fn = File.join(config_base, "pageinfo.yaml") unless config_base.nil?
      Pageinfo.setup(fn)
      @pageinfo = Pageinfo.load_config(fn)
    end

    def fetch_error(id, msg, time)
      return {
        id: SecureRandom.uuid,
        page_id: "unkown",
        page_name: "unkown",
        timestamp: 0,
        status: "unknown",
        error: true,
        service: id,
        error_msg: msg,
        error_ts: time.to_i
      }
    end

    def translate_status(status)
      return "up" if status == "good"
      return "down" if status == "bad"
      return "down" if status == "down"
      return status
    end

    def pluralize(singular, count, plural=nil)
      return "1 #{singular}" if count == 1
      plural = "#{singular}s" if plural.nil?
      return "#{count} #{plural}"
    end

    # shamelessly copied from https://stackoverflow.com/a/4136485/1480131
    # and modified by me
    def humanize_time(secs)
      [[60, :second], [60, :minute], [24, :hour], [31, :day], [12, :month], [1000, :year]].map{ |count, name|
        if secs > 0
          secs, n = secs.divmod(count)
          next nil if n == 0
          pluralize(name.to_s, n.to_i)
        end
      }.compact.reverse[0..1].join(' ')
    end
  end
end
