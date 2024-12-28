describe Lunargraph::TypeChecker do
  it "does not raise errors checking unparsed sources" do
    expect {
      checker = described_class.load_string(%(
        foo{
      ))
      checker.problems
    }.not_to raise_error
  end

  it "ignores tagged problems" do
    checker = described_class.load_string(%(
      NotAClass

      # @sg-ignore
      NotAClass
    ), nil, :strict)
    expect(checker.problems).to be_one
  end
end
