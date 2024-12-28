describe Lunargraph::Diagnostics do
  it "registers reporters" do
    described_class.register "base", Lunargraph::Diagnostics::Base
    expect(described_class.reporters).to include("base")
    expect(described_class.reporter("base")).to be(Lunargraph::Diagnostics::Base)
  end
end
