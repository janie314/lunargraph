describe Lunargraph::Pin::Base do
  let(:zero_location) { Lunargraph::Location.new("test.rb", Lunargraph::Range.from_to(0, 0, 0, 0)) }
  let(:one_location) { Lunargraph::Location.new("test.rb", Lunargraph::Range.from_to(0, 0, 1, 0)) }

  it "merges pins with location changes" do
    pin1 = described_class.new(location: zero_location, name: "Foo")
    pin2 = described_class.new(location: one_location, name: "Foo")
    expect(pin1.try_merge!(pin2)).to be(true)
    expect(pin1.location).to eq(one_location)
  end

  it "merges pins with comment changes" do
    pin1 = described_class.new(location: zero_location, name: "Foo", comments: "A Foo class")
    merge_comment = "A modified Foo class"
    pin2 = described_class.new(location: zero_location, name: "Foo", comments: merge_comment)
    expect(pin1.try_merge!(pin2)).to be(true)
    expect(pin1.comments).to eq(merge_comment)
  end

  it "does not merge pins with directive changes" do
    pin1 = described_class.new(location: zero_location, name: "Foo", comments: "A Foo class")
    pin2 = described_class.new(location: zero_location, name: "Foo", comments: "@!macro my_macro")
    expect(pin1.nearly?(pin2)).to be(false)
    expect(pin1.try_merge!(pin2)).to be(false)
  end

  it "does not merge pins with different directives" do
    pin1 = described_class.new(location: zero_location, name: "Foo", comments: "@!macro my_macro")
    pin2 = described_class.new(location: zero_location, name: "Foo", comments: "@!macro other")
    expect(pin1.nearly?(pin2)).to be(false)
    expect(pin1.try_merge!(pin2)).to be(false)
  end

  it "sees tag differences as not near or equal" do
    pin1 = described_class.new(location: zero_location, name: "Foo", comments: "@return [Foo]")
    pin2 = described_class.new(location: zero_location, name: "Foo", comments: "@return [Bar]")
    expect(pin1.nearly?(pin2)).to be(false)
    expect(pin1 == pin2).to be(false)
  end

  it "sees comment differences as nearly but not equal" do
    pin1 = described_class.new(location: zero_location, name: "Foo", comments: "A Foo class")
    pin2 = described_class.new(location: zero_location, name: "Foo", comments: "A different Foo")
    expect(pin1.nearly?(pin2)).to be(true)
    expect(pin1 == pin2).to be(false)
  end

  it "recognizes deprecated tags" do
    pin = described_class.new(location: zero_location, name: "Foo", comments: "@deprecated Use Bar instead.")
    expect(pin).to be_deprecated
  end

  it "does not link documentation for undefined return types" do
    pin = described_class.new(name: "Foo", comments: "@return [undefined]")
    expect(pin.link_documentation).to be_nil
  end
end
