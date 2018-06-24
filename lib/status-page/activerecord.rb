require "status-page/activerecord/activerecord"

dir = File.dirname(__FILE__)

Dir[File.join(dir, "activerecord", "*.rb")].each do |fn|
  fn = File.basename(fn, ".rb")

  next if fn == "activerecord"

  require "status-page/activerecord/#{fn}"
end
