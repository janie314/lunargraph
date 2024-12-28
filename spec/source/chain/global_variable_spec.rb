describe Lunargraph::Source::Chain::GlobalVariable do
  it "resolves instance variable pins" do
    closure = Lunargraph::Pin::Namespace.new(name: "Foo")
    foo_pin = Lunargraph::Pin::GlobalVariable.new(closure: closure, name: "$foo")
    not_pin = Lunargraph::Pin::InstanceVariable.new(closure: closure, name: "@bar")
    api_map = Lunargraph::ApiMap.new
    api_map.index [foo_pin, not_pin]
    link = described_class.new("$foo")
    pins = link.resolve(api_map, Lunargraph::ComplexType.parse("Foo"), [])
    expect(pins.length).to eq(1)
    expect(pins.first.name).to eq("$foo")
  end
end
