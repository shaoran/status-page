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
