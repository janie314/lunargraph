describe Lunargraph::Pin::Keyword do
  it "is a kind of keyword" do
    pin = described_class.new("foo")
    expect(pin.completion_item_kind).to eq(Lunargraph::LanguageServer::CompletionItemKinds::KEYWORD)
  end
end
