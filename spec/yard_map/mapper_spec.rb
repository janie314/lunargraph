describe Lunargraph::YardMap::Mapper do
  it "converts nil docstrings to empty strings" do
    dir = File.absolute_path(File.join("spec", "fixtures", "yard_map"))
    Dir.chdir dir do
      YARD::Registry.load([File.join(dir, "attr.rb")], true)
      mapper = described_class.new(YARD::Registry.all)
      pins = mapper.map
      pin = pins.find { |pin| pin.path == "Foo#bar" }
      expect(pin.comments).to be_a(String)
    end
    # Cleanup
    FileUtils.remove_entry_secure File.join(dir, ".yardoc")
  end

  it "marks explicit methods" do
    # Using rspec because it's a known dependency
    map = Lunargraph::YardMap.new(required: ["rspec"])
    pin = map.path_pin("RSpec::Matchers#be_truthy")
    expect(pin.explicit?).to be(true)
  end

  it "marks non-explicit methods" do
    # Using rspec because it's a known dependency
    map = Lunargraph::YardMap.new(required: ["rspec"])
    pin = map.path_pin("RSpec::Matchers#expect")
    expect(pin.explicit?).to be(false)
  end
end
