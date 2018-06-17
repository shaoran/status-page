RSpec.describe StatusPage do
  it "has a version number" do
    expect(StatusPage::VERSION).not_to be nil
  end
end

RSpec.describe StatusPage::JSONFetch do
  it "fetches a json response" do
    json = StatusPage::JSONFetch.fetch("https://pclby00q90vc.statuspage.io/api/v2/status.json")

    expect(json).not_to be nil
    expect(json.is_a?(Hash)).to be true
  end
end
