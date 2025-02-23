describe "NodeChainer" do
  it "recognizes self keywords" do
    chain = Lunargraph::Parser.chain_string("self.foo")
    expect(chain.links.first.word).to eq("self")
    expect(chain.links.first).to be_a(Lunargraph::Source::Chain::Head)
  end

  it "recognizes super keywords" do
    chain = Lunargraph::Parser.chain_string("super.foo")
    expect(chain.links.first.word).to eq("super")
    expect(chain.links.first).to be_a(Lunargraph::Source::Chain::ZSuper)
  end

  it "recognizes constants" do
    chain = Lunargraph::Parser.chain_string("Foo::Bar")
    expect(chain.links.length).to eq(1)
    expect(chain.links.first).to be_a(Lunargraph::Source::Chain::Constant)
    expect(chain.links.map(&:word)).to eq(["Foo::Bar"])
  end

  it "splits method calls with arguments and blocks" do
    chain = Lunargraph::Parser.chain_string("var.meth1(1, 2).meth2 do; end")
    expect(chain.links.map(&:word)).to eq(["var", "meth1", "meth2"])
  end

  it "recognizes literals" do
    chain = Lunargraph::Parser.chain_string('"string"')
    expect(chain).to be_literal
    chain = Lunargraph::Parser.chain_string("100")
    expect(chain).to be_literal
    chain = Lunargraph::Parser.chain_string("[1, 2, 3]")
    expect(chain).to be_literal
    chain = Lunargraph::Parser.chain_string('{ foo: "bar" }')
    expect(chain).to be_literal
  end

  it "recognizes instance variables" do
    chain = Lunargraph::Parser.chain_string("@foo")
    expect(chain.links.first).to be_a(Lunargraph::Source::Chain::InstanceVariable)
  end

  it "recognizes class variables" do
    chain = Lunargraph::Parser.chain_string("@@foo")
    expect(chain.links.first).to be_a(Lunargraph::Source::Chain::ClassVariable)
  end

  it "recognizes global variables" do
    chain = Lunargraph::Parser.chain_string("$foo")
    expect(chain.links.first).to be_a(Lunargraph::Source::Chain::GlobalVariable)
  end

  it "operates on nodes" do
    source = Lunargraph::Source.load_string(%(
      class Foo
        Bar.meth1(1, 2).meth2{}
      end
    ))
    node = source.node_at(2, 26)
    chain = Lunargraph::Parser.chain(node)
    expect(chain.links.map(&:word)).to eq(["Bar", "meth1", "meth2"])
  end

  it "chains and/or nodes" do
    source = Lunargraph::Source.load_string(%(
      [] || ''
    ))
    chain = Lunargraph::Parser.chain(source.node)
    expect(chain).to be_defined
  end

  it "tracks yielded blocks in methods" do
    source = Lunargraph::Source.load_string(%(
      Array.new.select { |foo| true }.first
    ))
    chain = Lunargraph::Parser.chain(source.node)
    # The `select` link has a yielded block and the `first` link does not
    expect(chain.links[-2].with_block?).to be(true)
    expect(chain.links.last.with_block?).to be(false)
  end

  it "tracks block-passes in methods" do
    source = Lunargraph::Source.load_string(%(
      Array.new.select(&:foo).first
    ))
    chain = Lunargraph::Parser.chain(source.node)
    # The `select` link has a yielded block and the `first` link does not
    expect(chain.links[-2].with_block?).to be(true)
    expect(chain.links.last.with_block?).to be(false)
  end

  it "tracks splat arguments" do
    source = Lunargraph::Source.load_string(%(
      foo(*bar)
    ))
    chain = Lunargraph::Parser.chain(source.node)
    expect(chain.links.first.arguments.last).to be_splat
  end

  it "tracks mixed splat arguments" do
    source = Lunargraph::Source.load_string(%(
      foo(bar, *baz)
    ))
    chain = Lunargraph::Parser.chain(source.node)
    expect(chain.links.first.arguments.last).to be_splat
  end

  it "tracks mixed block arguments" do
    source = Lunargraph::Source.load_string(%(
      foo(bar, &baz)
    ))
    chain = Lunargraph::Parser.chain(source.node)
    expect(chain.links.first.arguments.length).to eq(2)
  end
end
