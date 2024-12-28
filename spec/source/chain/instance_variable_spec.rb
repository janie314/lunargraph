describe Lunargraph::Source::Chain::InstanceVariable do
  it "resolves instance variable pins" do
    closure = Lunargraph::Pin::Namespace.new(name: "Foo")
    methpin = Lunargraph::Pin::Method.new(closure: closure, name: "imeth", scope: :instance)
    foo_pin = Lunargraph::Pin::InstanceVariable.new(closure: methpin, name: "@foo")
    bar_pin = Lunargraph::Pin::InstanceVariable.new(closure: closure, name: "@foo")
    api_map = Lunargraph::ApiMap.new
    api_map.index [closure, methpin, foo_pin, bar_pin]
    link = described_class.new("@foo")
    pins = link.resolve(api_map, methpin, [])
    expect(pins.length).to eq(1)
    expect(pins.first.name).to eq("@foo")
    expect(pins.first.context.scope).to eq(:instance)
    pins = link.resolve(api_map, closure, [])
    expect(pins.length).to eq(1)
    expect(pins.first.name).to eq("@foo")
    expect(pins.first.context.scope).to eq(:class)
  end
end
