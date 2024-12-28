describe Lunargraph::Parser do
  it "parses nodes" do
    node = described_class.parse("class Foo; end", "test.rb")
    expect(described_class.is_ast_node?(node)).to be(true)
  end
end
