describe Lunargraph::Source::Chain::Constant do
  it "resolves constants in the current context" do
    foo_pin = Lunargraph::Pin::Constant.new(name: "Foo", closure: Lunargraph::Pin::ROOT_PIN)
    api_map = Lunargraph::ApiMap.new
    api_map.index [foo_pin]
    link = described_class.new("Foo")
    pins = link.resolve(api_map, Lunargraph::Pin::ROOT_PIN, [])
    expect(pins).to eq([foo_pin])
  end
end
