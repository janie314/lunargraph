describe Lunargraph::Source::Updater do
  it "applies changes" do
    text = "foo"
    changes = []
    range = Lunargraph::Range.from_to(0, 3, 0, 3)
    new_text = "."
    changes.push Lunargraph::Source::Change.new(range, new_text)
    range = Lunargraph::Range.from_to(0, 4, 0, 4)
    new_text = "bar"
    changes.push Lunargraph::Source::Change.new(range, new_text)
    updater = described_class.new("file.rb", 0, changes)
    updated = updater.write(text)
    expect(updated).to eq("foo.bar")
  end

  it "applies repairs" do
    text = "foo"
    changes = []
    range = Lunargraph::Range.from_to(0, 3, 0, 3)
    new_text = "."
    changes.push Lunargraph::Source::Change.new(range, new_text)
    range = Lunargraph::Range.from_to(0, 4, 0, 4)
    new_text = "bar"
    changes.push Lunargraph::Source::Change.new(range, new_text)
    updater = described_class.new("file.rb", 0, changes)
    updated = updater.repair(text)
    expect(updated).to eq("foo    ")
  end

  it "handles nil ranges" do
    text = "foo"
    changes = []
    range = nil
    new_text = "bar"
    changes.push Lunargraph::Source::Change.new(range, new_text)
    updater = described_class.new("file.rb", 0, changes)
    updated = updater.write(text)
    expect(updated).to eq("bar")
  end
end
