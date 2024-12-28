describe Lunargraph::Pin::Namespace do
  it "handles long namespaces" do
    pin = described_class.new(closure: described_class.new(name: "Foo"), name: "Bar")
    expect(pin.path).to eq("Foo::Bar")
  end

  it "has class scope" do
    Lunargraph::Source.load_string(%(
      class Foo
      end
    ))
    pin = described_class.new(name: "Foo")
    expect(pin.context.scope).to eq(:class)
  end

  it "is a kind of namespace/class/module" do
    pin1 = described_class.new(name: "Foo")
    expect(pin1.completion_item_kind).to eq(Lunargraph::LanguageServer::CompletionItemKinds::CLASS)
    pin2 = described_class.new(name: "Foo", type: :module)
    expect(pin2.completion_item_kind).to eq(Lunargraph::LanguageServer::CompletionItemKinds::MODULE)
  end

  it "handles nested namespaces inside closures" do
    pin = described_class.new(closure: described_class.new(name: "Foo"), name: "Bar::Baz")
    expect(pin.namespace).to eq("Foo::Bar")
    expect(pin.name).to eq("Baz")
    expect(pin.path).to eq("Foo::Bar::Baz")
  end
end
