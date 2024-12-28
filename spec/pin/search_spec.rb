describe Lunargraph::Pin::Search do
  it "returns ordered matches on paths" do
    example_class = Lunargraph::Pin::Namespace.new(name: "Example")
    pins = [
      example_class,
      Lunargraph::Pin::Method.new(name: "foobar", closure: example_class),
      Lunargraph::Pin::Method.new(name: "foo_bar", closure: example_class)
    ]
    search = described_class.new(pins, "example")
    expect(search.results).to eq(pins)
  end

  it "returns ordered matches on names" do
    example_class = Lunargraph::Pin::Namespace.new(name: "Example")
    pins = [
      example_class,
      Lunargraph::Pin::Method.new(name: "foobar", closure: example_class),
      Lunargraph::Pin::Method.new(name: "foo_bar", closure: example_class)
    ]
    search = described_class.new(pins, "foobar")
    expect(search.results.map(&:path)).to eq(["Example.foobar", "Example.foo_bar"])
  end

  it "filters insufficient matches" do
    example_class = Lunargraph::Pin::Namespace.new(name: "Example")
    pins = [
      example_class,
      Lunargraph::Pin::Method.new(name: "foobar", closure: example_class),
      Lunargraph::Pin::Method.new(name: "bazquz", closure: example_class)
    ]
    search = described_class.new(pins, "foobar")
    expect(search.results.map(&:path)).to eq(["Example.foobar"])
  end
end
