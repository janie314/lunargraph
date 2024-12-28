describe Lunargraph::LanguageServer::Host::Cataloger do
  it "catalogs on ticks" do
    host = double(Lunargraph::LanguageServer::Host)
    cataloger = described_class.new(host)
    expect(host).to receive(:catalog)
    cataloger.tick
  end
end
