RSpec.describe StatusPage do
  it "has a version number" do
    expect(StatusPage::VERSION).not_to be nil
  end
end

RSpec.describe StatusPage::JSONFetch do
  it "fetches a json statuspage_response" do
    json = StatusPage::JSONFetch.fetch("https://pclby00q90vc.statuspage.io/api/v2/status.json")

    expect(json).not_to be nil
    expect(json.is_a?(Hash)).to be true
  end

  it "fetches a json github_response" do
    json = StatusPage::JSONFetch.fetch("https://status.github.com/api/status.json")

    expect(json).not_to be nil
    expect(json.is_a?(Hash)).to be true
  end
end


RSpec.describe StatusPage::Query do
  obj = { a: 1, b: 2, c:3, d:4 }

  q11 = _QAND(a:1, b: 2)
  q12 = _QAND(x: 3, y: "hello")
  q13 = _QAND(xx: q11, yy: _QNOT(q12))

  q21 = _QOR(x: 34)
  q22 = _QOR(min: 2, max: "max", d:4)
  q23 = _QNOT(a: 12)


  it "query q11 to filter correctly" do
    expect(q11.filter(obj)).to be true
  end

  it "query q12 to filter correctly" do
    expect(q12.filter(obj)).to be false
  end

  it "query q13 to filter correctly" do
    expect(q13.filter(obj)).to be true
  end

  it "query q21 to filter correctly" do
    expect(q21.filter(obj)).to be false
  end

  it "query q22 to filter correctly" do
    expect(q22.filter(obj)).to be true
  end

  it "query q23 to filter correctly" do
    expect(q23.filter(obj)).to be true
  end
end

RSpec.describe StatusPage::ActiveRecord do
  base = File.join("/", "tmp", "status-page", "db")
  fn = File.join(base, "TestRecord.json")

  system("rm -rf #{fn}")

  class TestRecord < StatusPage::ActiveRecord
  end

  TestRecord.db_base = base
  TestRecord.reload_cache()

  it "creates a new storage file #{fn}" do
    expect(Pathname.new(fn)).to exist
  end

  it "find() method returns empty array" do
    expect(TestRecord.all).to be_empty
  end

  it "Saves a record successfully" do
    nr = TestRecord.new a: 1, b:2, c:3
    nr.save!

    # clearing cache
    TestRecord.wholedata.clear()

    # restoring cache
    TestRecord.reload_cache()

    all = TestRecord.all

    expect(all).not_to be_empty

    expect(all[0].is_a?(TestRecord)).to be_truthy

    expect(all[0].b).to be 2

  end

end



RSpec.describe "Parser" do

    statuspage_response = {"page"=>{"id"=>"pclby00q90vc", "name"=>"RubyGems.org", "url"=>"https://status.rubygems.org", "time_zone"=>"Etc/UTC", "updated_at"=>"2018-06-17T22:55:20.374Z"}, "status"=>{"indicator"=>"none", "description"=>"All Systems Operational"}}

    github_response = {"status"=>"good", "last_updated"=>"2018-06-11T16:50:02Z"}

  it "parses the JSON statuspage_response of the status page" do
    info = StatusPage::StatusPageParser.parse(statuspage_response)

    expect(info).not_to be nil
  end

  expected = {:page_id=>"pclby00q90vc", :page_name=>"RubyGems.org", :timestamp=>1529276120, "status"=>"good"}

  expected.each do |key,val|
    info = StatusPage::StatusPageParser.parse(statuspage_response)

    it "expects to find #{key.inspect}" do
      expect(info.include?(key)).to be_truthy
    end

    it "expects to find #{key.inspect} with value #{val.inspect}" do
      expect(info[key]).to eq(val)
    end
  end


  it "parses the JSON github_response of the status page" do
    info = StatusPage::GitHubParser::parse(github_response)
    expect(info).not_to be nil
  end

  expected = {:page_id=>"github", :page_name=>"github.com", :timestamp=>1528735802, "status"=>"good"}


  expected.each do |key,val|
    info = StatusPage::GitHubParser::parse(github_response)

    it "expects to find #{key.inspect}" do
      expect(info.include?(key)).to be_truthy
    end

    it "expects to find #{key.inspect} with value #{val.inspect}" do
      expect(info[key]).to eq(val)
    end
  end

end

