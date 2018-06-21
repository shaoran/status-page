require "fileutils"
require "yaml"

module StatusPage

  class Pageinfo

    @@pi_config = File.join(Dir.home, ".config", "pageinfo.yaml")

    def self.pi_config=(path)
      @@pi_config = path
    end

    def self.pi_config
      @@pi_config
    end

    def self.setup
      default = {
        "pages" => {
          "Bitbucket" => {
            "parser" => "StatusPageParser",
            "url"    => "https://bqlf8qjztdtr.statuspage.io/api/v2/status.json",
          },

          "Cloudflare" => {
            "parser" => "StatusPageParser",
            "url"    => "https://yh6f0r4529hb.statuspage.io/api/v2/status.json",
          },

          "RubyGems.org" => {
            "parser" => "StatusPageParser",
            "url"    => "https://pclby00q90vc.statuspage.io/api/v2/status.json",
          },

          "Github" => {
            "parser" => "GitHubParser",
            "url"    => "https://status.github.com/api/status.json",
          },
        }
      }

      return if File.exists?(@@pi_config)

      dir = File.dirname(@@pi_config)

      FileUtils.mkdir_p(dir) unless Dir.exists?(dir)

      File.open(@@pi_config, "w") do |fp|
        fp.write(YAML.dump(default))
      end
    end

    def self.load_config
      cnf = File.read(@@pi_config)

      pi = YAML.load(cnf)

      self.new(pi)
    end


    attr_accessor :pageinfo

    def initialize(pageinfo)
      @pageinfo = pageinfo["pages"]

      @pageinfo.each do |id,config|
        parser = config["parser"]

        parser = StatusPage.const_get(parser)

        config["parser"] = parser
      end
    end

    # returns list of pages
    def list
      @pageinfo.map { |id,config| id }
    end

    def [](key)
      pi = @pageinfo[key]
      return pi unless pi.nil?

      keyU = key.upcase
      @pageinfo.each do |id,config|
        next if id.upcase != keyU
        return config
      end
    end


  end

end
