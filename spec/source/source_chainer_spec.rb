describe Lunargraph::Source::SourceChainer do
  it "handles trailing colons that are not namespace separators" do
    source = Lunargraph::Source.load_string("Foo:")
    map = Lunargraph::SourceMap.map(source)
    cursor = map.cursor_at(Lunargraph::Position.new(0, 4))
    expect(cursor.chain.links.first).to be_undefined
  end

  it "recognizes literal strings" do
    map = Lunargraph::SourceMap.load_string("'string'")
    cursor = map.cursor_at(Lunargraph::Position.new(0, 0))
    expect(cursor.chain).not_to be_a(Lunargraph::Source::Chain::Literal)
    cursor = map.cursor_at(Lunargraph::Position.new(0, 1))
    expect(cursor.chain.links.first).to be_a(Lunargraph::Source::Chain::Literal)
    expect(cursor.chain.links.first.word).to eq("<::String>")
  end

  it "recognizes literal integers" do
    map = Lunargraph::SourceMap.load_string("100")
    cursor = map.cursor_at(Lunargraph::Position.new(0, 0))
    expect(cursor.chain).not_to be_a(Lunargraph::Source::Chain::Literal)
    cursor = map.cursor_at(Lunargraph::Position.new(0, 1))
    expect(cursor.chain.links.first).to be_a(Lunargraph::Source::Chain::Literal)
    expect(cursor.chain.links.first.word).to eq("<::Integer>")
  end

  it "recognizes literal regexps" do
    map = Lunargraph::SourceMap.load_string("/[a-z]/")
    cursor = map.cursor_at(Lunargraph::Position.new(0, 0))
    expect(cursor.chain.links.first).to be_a(Lunargraph::Source::Chain::Literal)
    expect(cursor.chain.links.first.word).to eq("<::Regexp>")
  end

  it "recognizes class variables" do
    map = Lunargraph::SourceMap.load_string("@@foo")
    cursor = map.cursor_at(Lunargraph::Position.new(0, 0))
    expect(cursor.chain.links.first).to be_a(Lunargraph::Source::Chain::ClassVariable)
    expect(cursor.chain.links.first.word).to eq("@@foo")
  end

  it "recognizes instance variables" do
    map = Lunargraph::SourceMap.load_string("@foo")
    cursor = map.cursor_at(Lunargraph::Position.new(0, 0))
    expect(cursor.chain.links.first).to be_a(Lunargraph::Source::Chain::InstanceVariable)
    expect(cursor.chain.links.first.word).to eq("@foo")
  end

  it "recognizes global variables" do
    map = Lunargraph::SourceMap.load_string("$foo")
    cursor = map.cursor_at(Lunargraph::Position.new(0, 0))
    expect(cursor.chain.links.first).to be_a(Lunargraph::Source::Chain::GlobalVariable)
    expect(cursor.chain.links.first.word).to eq("$foo")
  end

  it "recognizes constants" do
    map = Lunargraph::SourceMap.load_string("Foo::Bar")
    cursor = map.cursor_at(Lunargraph::Position.new(0, 6))
    expect(cursor.chain).to be_constant
    expect(cursor.chain.links.map(&:word)).to eq(["Foo::Bar"])
  end

  it "recognizes unfinished constants" do
    map = Lunargraph::SourceMap.load_string("Foo:: $something")
    cursor = map.cursor_at(Lunargraph::Position.new(0, 5))
    expect(cursor.chain).to be_constant
    expect(cursor.chain.links.map(&:word)).to eq(["Foo", "<undefined>"])
    expect(cursor.chain).to be_undefined
  end

  it "recognizes unfinished calls" do
    orig = Lunargraph::Source.load_string("foo.bar")
    updater = Lunargraph::Source::Updater.new(nil, 1, [
      Lunargraph::Source::Change.new(Lunargraph::Range.from_to(0, 7, 0, 7), ".")
    ])
    source = orig.synchronize(updater)
    map = Lunargraph::SourceMap.map(source)
    cursor = map.cursor_at(Lunargraph::Position.new(0, 8))
    expect(cursor.chain.links.last).to be_a(Lunargraph::Source::Chain::Call)
    expect(cursor.chain.links.map(&:word)).to eq(["foo", "bar", "<undefined>"])
    expect(cursor.chain).to be_undefined
  end

  it "chains signatures with square brackets" do
    map = Lunargraph::SourceMap.load_string("foo[0].bar")
    cursor = map.cursor_at(Lunargraph::Position.new(0, 8))
    expect(cursor.chain.links.map(&:word)).to eq(["foo", "[]", "bar"])
  end

  it "chains signatures with curly brackets" do
    map = Lunargraph::SourceMap.load_string("foo{|x| x == y}.bar")
    cursor = map.cursor_at(Lunargraph::Position.new(0, 16))
    expect(cursor.chain.links.map(&:word)).to eq(["foo", "bar"])
  end

  it "chains signatures with parentheses" do
    map = Lunargraph::SourceMap.load_string("foo(x, y).bar")
    cursor = map.cursor_at(Lunargraph::Position.new(0, 10))
    expect(cursor.chain.links.map(&:word)).to eq(["foo", "bar"])
  end

  it "chains from repaired sources with literal strings" do
    orig = Lunargraph::Source.load_string("''")
    updater = Lunargraph::Source::Updater.new(
      nil,
      2,
      [
        Lunargraph::Source::Change.new(
          Lunargraph::Range.from_to(0, 2, 0, 2),
          "."
        )
      ]
    )
    source = orig.synchronize(updater)
    chain = described_class.chain(source, Lunargraph::Position.new(0, 3))
    expect(chain.links.first).to be_a(Lunargraph::Source::Chain::Literal)
    expect(chain.links.length).to eq(2)
  end

  it "chains incomplete constants" do
    source = Lunargraph::Source.load_string("Foo::")
    chain = described_class.chain(source, Lunargraph::Position.new(0, 5))
    expect(chain.links.length).to eq(2)
    expect(chain.links.first).to be_a(Lunargraph::Source::Chain::Constant)
    expect(chain.links.last).to be_a(Lunargraph::Source::Chain::Constant)
    expect(chain.links.last).to be_undefined
  end

  it "works when source error ranges contain a nil range" do
    orig = Lunargraph::Source.load_string("msg = 'msg'\nmsg", "test.rb")
    updater = Lunargraph::Source::Updater.new("test.rb", 1, [
      Lunargraph::Source::Change.new(nil, "msg = 'msg'\nmsg.")
    ])
    source = orig.synchronize(updater)
    expect {
      described_class.chain(source, Lunargraph::Position.new(1, 4))
    }.not_to raise_error
  end

  it "stops phrases at opening brackets" do
    source = Lunargraph::Source.load_string(%(
      (aa1, 2, 3)
      [bb2, 2, 3]
      {cc3, 2, 3}
    ))
    chain = described_class.chain(source, Lunargraph::Position.new(1, 10))
    expect(chain.links.first.word).to eq("aa1")
    chain = described_class.chain(source, Lunargraph::Position.new(2, 10))
    expect(chain.links.first.word).to eq("bb2")
    chain = described_class.chain(source, Lunargraph::Position.new(3, 10))
    expect(chain.links.first.word).to eq("cc3")
  end

  it "chains instance variables from unsynchronized sources" do
    source = double(Lunargraph::Source,
      synchronized?: false,
      code: "@foo.",
      filename: "test.rb",
      string_at?: false,
      comment_at?: false,
      repaired?: false,
      parsed?: true,
      error_ranges: [],
      node_at: nil,
      tree_at: [])
    chain = described_class.chain(source, Lunargraph::Position.new(0, 5))
    expect(chain.links.first.word).to eq("@foo")
    expect(chain.links.last.word).to eq("<undefined>")
  end

  it "chains class variables from unsynchronized sources" do
    source = double(Lunargraph::Source,
      synchronized?: false,
      code: "@@foo.",
      filename: "test.rb",
      string_at?: false,
      comment_at?: false,
      repaired?: false,
      parsed?: true,
      error_ranges: [],
      node_at: nil,
      tree_at: [])
    chain = described_class.chain(source, Lunargraph::Position.new(0, 6))
    expect(chain.links.first.word).to eq("@@foo")
    expect(chain.links.last.word).to eq("<undefined>")
  end

  it "detects literals from chains in unsynchronized sources" do
    source1 = Lunargraph::Source.load_string(%(
      ''
    ))
    source2 = source1.start_synchronize(Lunargraph::Source::Updater.new(
      nil,
      2,
      [
        Lunargraph::Source::Change.new(
          Lunargraph::Range.from_to(1, 8, 1, 8),
          "."
        )
      ]
    ))
    chain = described_class.chain(source2, Lunargraph::Position.new(1, 9))
    expect(chain.links.first).to be_a(Lunargraph::Source::Chain::Literal)
    expect(chain.links.first.word).to eq("<::String>")
    expect(chain.links.last.word).to eq("<undefined>")
  end

  it "ignores ? and ! that are not method suffixes" do
    source = Lunargraph::Source.load_string(%(
      if !t
    ), "test.rb")
    chain = described_class.chain(source, Lunargraph::Position.new(1, 11))
    expect(chain.links.length).to eq(1)
    expect(chain.links.first.word).to eq("t")
  end

  it "chains from fixed phrases in repaired sources with missing nodes" do
    source = Lunargraph::Source.load_string(%(
      x = []

    ), "test.rb")
    updater = Lunargraph::Source::Updater.new("test.rb", 1, [
      Lunargraph::Source::Change.new(Lunargraph::Range.from_to(2, 6, 2, 6), "x.")
    ])
    updated = source.start_synchronize(updater)
    cursor = updated.cursor_at(Lunargraph::Position.new(2, 8))
    expect(cursor.chain.links.first.word).to eq("x")
  end

  it "handles integers with dots at end of file" do
    source = Lunargraph::Source.load_string("100.")
    chain = described_class.chain(source, Lunargraph::Position.new(0, 4))
    expect(chain.links.length).to eq(2)
    expect(chain.links.first).to be_a(Lunargraph::Source::Chain::Literal)
    expect(chain.links.last).to be_undefined
  end

  it "detects whole constant with cursor at double colon" do
    source = Lunargraph::Source.load_string(%(
      class Outer
        class Inner
        end
      end
      Outer::Inner.new
    ), "test.rb")
    chain = described_class.chain(source, Lunargraph::Position.new(5, 13))
    expect(chain.links.last.word).to eq("Outer::Inner")
  end

  it "detects whole constant with cursor at double colon" do
    source = Lunargraph::Source.load_string(%(
      class Outer
        class Inner1
          class Inner2
          end
        end
      end
      Outer::Inner1::Inner2.new
    ), "test.rb")
    chain = described_class.chain(source, Lunargraph::Position.new(7, 21))
    expect(chain.links.last.word).to eq("Outer::Inner1::Inner2")
  end

  it "chains combined optargs and kwoptargs" do
    source = Lunargraph::Source.load_string(%(
      foo(*optargs, **kwargs)
    ), "test.rb")
    chain = described_class.chain(source, Lunargraph::Position.new(1, 7))
    expect(chain.links.last.arguments.length).to eq(2)
  end
end
