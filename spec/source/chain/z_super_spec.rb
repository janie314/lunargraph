describe Lunargraph::Source::Chain::ZSuper do
  it "resolves super" do
    head = described_class.new("super")
    npin = Lunargraph::Pin::Namespace.new(name: "Substring")
    scpin = Lunargraph::Pin::Reference::Superclass.new(closure: npin, name: "String")
    mpin = Lunargraph::Pin::Method.new(closure: npin, name: "upcase", scope: :instance, visibility: :public)
    api_map = Lunargraph::ApiMap.new(pins: [npin, scpin, mpin])
    spin = head.resolve(api_map, mpin, []).first
    expect(spin.path).to eq("String#upcase")
  end
end
