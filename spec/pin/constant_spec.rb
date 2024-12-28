describe Lunargraph::Pin::Constant do
  it "resolves constant paths" do
    source = Lunargraph::Source.new(%(
      class Foo
        BAR = 'bar'
      end
    ))
    map = Lunargraph::SourceMap.map(source)
    pin = map.pins.find { |pin| pin.name == "BAR" }
    expect(pin.path).to eq("Foo::BAR")
  end

  it "is a constant kind" do
    source = Lunargraph::Source.new(%(
      class Foo
        BAR = 'bar'
      end
    ))
    map = Lunargraph::SourceMap.map(source)
    pin = map.pins.find { |pin| pin.name == "BAR" }
    expect(pin.completion_item_kind).to eq(Lunargraph::LanguageServer::CompletionItemKinds::CONSTANT)
    expect(pin.symbol_kind).to eq(Lunargraph::LanguageServer::SymbolKinds::CONSTANT)
  end
end
