describe Lunargraph::LanguageServer::Message::CompletionItem::Resolve do
  it "returns MarkupContent for documentation" do
    pin = Lunargraph::Pin::Method.new(
      location: nil,
      closure: Lunargraph::Pin::Namespace.new(name: "Foo"),
      name: "bar",
      comments: "A method",
      scope: :instance,
      visibility: :public,
      parameters: []
    )
    host = double(Lunargraph::LanguageServer::Host, locate_pins: [pin], probe: pin, detail: nil, options: { "enablePages" => true })
    resolve = described_class.new(host, {
      "params" => pin.completion_item
    })
    resolve.process
    expect(resolve.result[:documentation][:kind]).to eq("markdown")
    expect(resolve.result[:documentation][:value]).to include("A method")
  end

  it "returns nil documentation for empty strings" do
    pin = Lunargraph::Pin::InstanceVariable.new(
      location: nil,
      closure: Lunargraph::Pin::Namespace.new(name: "Foo"),
      name: "@bar",
      comments: ""
    )
    host = double(Lunargraph::LanguageServer::Host, locate_pins: [pin], probe: pin, detail: nil)
    resolve = described_class.new(host, {
      "params" => pin.completion_item
    })
    resolve.process
    expect(resolve.result[:documentation]).to be_nil
  end
end
