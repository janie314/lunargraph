describe Lunargraph::Pin::InstanceVariable do
  it "is a kind of variable" do
    source = Lunargraph::Source.load_string("@foo = 'foo'", "file.rb")
    map = Lunargraph::SourceMap.map(source)
    pin = map.pins.find { |p| p.is_a?(described_class) }
    expect(pin.completion_item_kind).to eq(Lunargraph::LanguageServer::CompletionItemKinds::VARIABLE)
    expect(pin.symbol_kind).to eq(Lunargraph::LanguageServer::SymbolKinds::VARIABLE)
  end

  it "does not link documentation for undefined return types" do
    pin = described_class.new(name: "@bar")
    expect(pin.link_documentation).to be_nil
  end
end
