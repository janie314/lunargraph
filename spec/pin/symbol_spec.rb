describe Lunargraph::Pin::Symbol do
  it "is a kind of keyword" do
    pin = described_class.new(nil, ":symbol")
    expect(pin.completion_item_kind).to eq(Lunargraph::LanguageServer::CompletionItemKinds::KEYWORD)
  end

  it "has a Symbol return type" do
    pin = described_class.new(nil, ":symbol")
    expect(pin.return_type.tag).to eq("Symbol")
  end
end
