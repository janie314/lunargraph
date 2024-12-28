describe Lunargraph::Diagnostics::UpdateErrors do
  it "detects repaired lines" do
    api_map = Lunargraph::ApiMap.new
    orig = Lunargraph::Source.load_string("foo", "test.rb")
    diagnoser = described_class.new
    result = diagnoser.diagnose(orig, api_map)
    expect(result.length).to eq(0)
    updater = Lunargraph::Source::Updater.new("test.rb", 2, [
      Lunargraph::Source::Change.new(
        Lunargraph::Range.from_to(0, 3, 0, 3),
        "."
      )
    ])
    source = orig.synchronize(updater)
    diagnoser = described_class.new
    result = diagnoser.diagnose(source, api_map)
    expect(result.length).to eq(1)
  end
end
