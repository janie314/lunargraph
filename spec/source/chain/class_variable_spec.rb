describe Lunargraph::Source::Chain::ClassVariable do
  it "resolves class variable pins" do
    foo_pin = Lunargraph::Pin::ClassVariable.new(name: "@@foo")
    bar_pin = Lunargraph::Pin::ClassVariable.new(name: "@@bar")
    api_map = double(Lunargraph::ApiMap, get_class_variable_pins: [foo_pin, bar_pin])
    link = described_class.new("@@bar")
    pins = link.resolve(api_map, Lunargraph::Pin::ROOT_PIN, [])
    expect(pins.length).to eq(1)
    expect(pins.first.name).to eq("@@bar")
  end
end
