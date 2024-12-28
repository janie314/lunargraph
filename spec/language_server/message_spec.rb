describe Lunargraph::LanguageServer::Message do
  it "returns MethodNotFound for unregistered methods" do
    msg = described_class.select "notARealMethod"
    expect(msg).to be(Lunargraph::LanguageServer::Message::MethodNotFound)
  end

  it "returns MethodNotImplemented for unregistered $ methods" do
    msg = described_class.select "$/notARealMethod"
    expect(msg).to be(Lunargraph::LanguageServer::Message::MethodNotImplemented)
  end
end
