describe Lunargraph::Position do
  it "normalizes arrays into positions" do
    pos = described_class.normalize([0, 1])
    expect(pos).to be_a(described_class)
    expect(pos.line).to eq(0)
    expect(pos.column).to eq(1)
  end

  it "returns original positions when normalizing" do
    orig = described_class.new(0, 1)
    norm = described_class.normalize(orig)
    expect(orig).to be(norm)
  end

  it "raises an error for objects that cannot be normalized" do
    expect {
      described_class.normalize("0, 1")
    }.to raise_error(ArgumentError)
  end
end
