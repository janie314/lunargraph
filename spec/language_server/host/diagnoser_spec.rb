describe Lunargraph::LanguageServer::Host::Diagnoser do
  it "diagnoses on ticks" do
    host = double(Lunargraph::LanguageServer::Host, options: { "diagnostics" => true }, synchronizing?: false)
    diagnoser = described_class.new(host)
    diagnoser.schedule "file.rb"
    expect(host).to receive(:diagnose).with("file.rb")
    diagnoser.tick
  end
end
