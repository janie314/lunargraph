# These tests are deliberately generic because they apply to both the Legacy
# and Rubyvm node methods.
describe Lunargraph::Parser::NodeMethods do
  it "unpacks constant nodes into strings" do
    ast = Lunargraph::Parser.parse("Foo::Bar")
    expect(described_class.unpack_name(ast)).to eq "Foo::Bar"
  end

  it "infers literal strings" do
    ast = Lunargraph::Parser.parse("x = 'string'")
    expect(described_class.infer_literal_node_type(ast.children[1])).to eq "::String"
  end

  it "infers literal hashes" do
    ast = Lunargraph::Parser.parse("x = {}")
    expect(described_class.infer_literal_node_type(ast.children[1])).to eq "::Hash"
  end

  it "infers literal arrays" do
    ast = Lunargraph::Parser.parse("x = []")
    expect(described_class.infer_literal_node_type(ast.children[1])).to eq "::Array"
  end

  it "infers literal integers" do
    ast = Lunargraph::Parser.parse("x = 100")
    expect(described_class.infer_literal_node_type(ast.children[1])).to eq "::Integer"
  end

  it "infers literal floats" do
    ast = Lunargraph::Parser.parse("x = 10.1")
    expect(described_class.infer_literal_node_type(ast.children[1])).to eq "::Float"
  end

  it "infers literal symbols" do
    ast = Lunargraph::Parser.parse(":symbol")
    expect(described_class.infer_literal_node_type(ast)).to eq "::Symbol"
  end

  it "infers literal booleans" do
    true_ast = Lunargraph::Parser.parse("true")
    expect(described_class.infer_literal_node_type(true_ast)).to eq "::Boolean"
    false_ast = Lunargraph::Parser.parse("false")
    expect(described_class.infer_literal_node_type(false_ast)).to eq "::Boolean"
  end

  it "handles return nodes with implicit nil values" do
    node = Lunargraph::Parser.parse(%(
      return if true
    ))
    rets = described_class.returns_from(node)
    # @todo Should there be two returns, the second being nil?
    expect(rets.length).to eq(2)
  end

  it "handles return nodes with implicit nil values" do
    node = Lunargraph::Parser.parse(%(
      return bla if true
    ))
    rets = described_class.returns_from(node)
    # Two returns, the second being implicit nil
    expect(rets.length).to eq(2)
  end

  it "handles return nodes from case statements" do
    node = Lunargraph::Parser.parse(%(
      case x
      when 100
        true
      end
    ))
    returns = described_class.returns_from(node)
    # Include an implicit `nil` for missing else
    expect(returns.length).to eq(2)
  end

  it "handles return nodes from case statements with else" do
    node = Lunargraph::Parser.parse(%(
      case x
      when 100
        true
      else
        false
      end
    ))
    returns = described_class.returns_from(node)
    expect(returns.length).to eq(2)
  end

  it "handles return nodes from case statements with boolean conditions" do
    node = Lunargraph::Parser.parse(%(
      case true
      when x
        true
      else
        false
      end
    ))
    returns = described_class.returns_from(node)
    expect(returns.length).to eq(2)
  end

  it "handles return nodes in reduceable (begin) nodes" do
    # @todo Temporarily disabled. Result is 3 nodes instead of 2.
    # node = Lunargraph::Parser.parse(%(
    #   begin
    #     return if true
    #   end
    # ))
    # rets = Lunargraph::Parser::NodeMethods.returns_from(node)
    # expect(rets.length).to eq(2)
  end

  it "handles return nodes after other nodes" do
    node = Lunargraph::Parser.parse(%(
      x = 1
      return x
    ))
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(1)
  end

  it "handles return nodes with unreachable code" do
    node = Lunargraph::Parser.parse(%(
      x = 1
      return x
      y
    ))
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(1)
  end

  it "handles conditional returns with following code" do
    node = Lunargraph::Parser.parse(%(
      x = 1
      return x if foo
      y
    ))
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(2)
  end

  it "handles return nodes with reduceable code" do
    node = Lunargraph::Parser.parse(%(
      return begin
        x if foo
        y
      end
    ))
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(1)
  end

  it "handles top 'and' nodes" do
    node = Lunargraph::Parser.parse('1 && "2"')
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(1)
    expect(rets[0].type.to_s.downcase).to eq("and")
  end

  it "handles top 'or' nodes" do
    node = Lunargraph::Parser.parse('1 || "2"')
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(2)
    expect(described_class.infer_literal_node_type(rets[0])).to eq("::Integer")
    expect(described_class.infer_literal_node_type(rets[1])).to eq("::String")
  end

  it "handles nested 'and' nodes" do
    node = Lunargraph::Parser.parse('return 1 && "2"')
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(1)
    expect(rets[0].type.to_s.downcase).to eq("and")
  end

  it "handles nested 'or' nodes" do
    node = Lunargraph::Parser.parse('return 1 || "2"')
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(2)
    expect(described_class.infer_literal_node_type(rets[0])).to eq("::Integer")
    expect(described_class.infer_literal_node_type(rets[1])).to eq("::String")
  end

  it "finds return nodes in blocks" do
    node = Lunargraph::Parser.parse(%(
      array.each do |item|
        return item if foo
      end
    ))
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(2)
    expect([:lvar, :DVAR]).to include(rets[1].type)
  end

  it "returns nested return blocks" do
    node = Lunargraph::Parser.parse(%(
      if foo
        array.each do |item|
          return item if foo
        end
      end
      nil
    ))
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(2)
    expect([:lvar, :DVAR]).to include(rets[0].type)
  end

  it "handles return nodes with implicit nil values" do
    node = Lunargraph::Parser.parse(%(
      return if true
    ))
    rets = described_class.returns_from(node)
    # The expectation is changing from previous versions. If conditions
    # have an implicit else branch, so this node should return [nil, nil].
    expect(rets.length).to eq(2)
  end

  it "handles return nodes with implicit nil values" do
    node = Lunargraph::Parser.parse(%(
      return bla if true
    ))
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(2)
  end

  it "handles return nodes in reduceable (begin) nodes" do
    # @todo Temporarily disabled. Result is 3 nodes instead of 2 in legacy.
    # node = Lunargraph::Parser.parse(%(
    #   begin
    #     return if true
    #   end
    # ))
    # rets = Lunargraph::Parser::NodeMethods.returns_from(node)
    # expect(rets.length).to eq(2)
  end

  it "handles return nodes after other nodes" do
    node = Lunargraph::Parser.parse(%(
      x = 1
      return x
    ))
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(1)
  end

  it "handles return nodes with unreachable code" do
    node = Lunargraph::Parser.parse(%(
      x = 1
      return x
      y
    ))
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(1)
  end

  it "handles conditional returns with following code" do
    node = Lunargraph::Parser.parse(%(
      x = 1
      return x if foo
      y
    ))
    rets = described_class.returns_from(node)
    # Another implicit else branch. This should have 3 return nodes.
    expect(rets.length).to eq(2)
  end

  it "handles return nodes with reduceable code" do
    node = Lunargraph::Parser.parse(%(
      return begin
        x if foo
        y
      end
    ))
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(1)
  end

  it "handles top 'and' nodes" do
    node = Lunargraph::Parser.parse('1 && "2"')
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(1)
  end

  it "handles top 'or' nodes" do
    node = Lunargraph::Parser.parse('1 || "2"')
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(2)
    # expect(rets[0].type).to eq(:LIT)
    # expect(rets[1].type).to eq(:STR)
  end

  it "handles nested 'and' nodes" do
    node = Lunargraph::Parser.parse('return 1 && "2"')
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(1)
  end

  it "handles nested 'or' nodes" do
    node = Lunargraph::Parser.parse('return 1 || "2"')
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(2)
    # expect(rets[0].type).to eq(:LIT)
    # expect(rets[1].type).to eq(:STR)
  end

  it "finds return nodes in blocks" do
    node = Lunargraph::Parser.parse(%(
      array.each do |item|
        return item if foo
      end
    ))
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(2)
    # expect(rets[1].type).to eq(:DVAR)
  end

  it "returns nested return blocks" do
    node = Lunargraph::Parser.parse(%(
      if foo
        array.each do |item|
          return item if foo
        end
      end
      nil
    ))
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(2)
    # expect(rets[0].type).to eq(:DVAR)
  end

  it "handles return nodes from case statements" do
    node = Lunargraph::Parser.parse(%(
      case 1
      when 1 then ""
      else
        ""
      end
    ))
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(2)
  end

  it "handles return nodes from case statements without else" do
    node = Lunargraph::Parser.parse(%(
      case 1
      when 1
        ""
      end
    ))
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(2)
  end

  it "handles return nodes from case statements with super" do
    node = Lunargraph::Parser.parse(%(
      case other
      when Docstring
        Docstring.new([all, other.all].join("\n"), object)
      else
        super
      end
    ))
    rets = described_class.returns_from(node)
    expect(rets.length).to eq(2)
  end

  describe "convert_hash" do
    it "converts literal hash arguments" do
      node = Lunargraph::Parser.parse("{foo: :bar}")
      hash = described_class.convert_hash(node)
      expect(hash.keys).to eq([:foo])
    end

    it "ignores call arguments" do
      node = Lunargraph::Parser.parse("some_call")
      hash = described_class.convert_hash(node)
      expect(hash).to eq({})
    end
  end

  describe "call_nodes_from" do
    it "handles super calls" do
      source = Lunargraph::Source.load_string(%(
        class Foo
          def super_with_block
            super { |record| }
          end
        end
      ))
      calls = described_class.call_nodes_from(source.node)
      expect(calls).to be_one
    end
  end
end
