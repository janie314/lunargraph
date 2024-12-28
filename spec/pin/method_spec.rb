describe Lunargraph::Pin::Method do
  it "tracks code parameters" do
    source = Lunargraph::Source.new(%(
      def foo bar, baz = MyClass.new
      end
    ))
    map = Lunargraph::SourceMap.map(source)
    pin = map.pins.find { |pin| pin.path == "#foo" }
    expect(pin.parameters.length).to eq(2)
    expect(pin.parameters[0].name).to eq("bar")
    expect(pin.parameters[1].name).to eq("baz")
    expect(pin.parameter_names).to eq(%w[bar baz])
  end

  it "tracks keyword parameters" do
    source = Lunargraph::Source.new(%(
      def foo bar:, baz: MyClass.new
      end
    ))
    map = Lunargraph::SourceMap.map(source)
    pin = map.pins.find { |pin| pin.path == "#foo" }
    expect(pin.parameters.length).to eq(2)
    expect(pin.parameters[0].name).to eq("bar")
    expect(pin.parameters[1].name).to eq("baz")
    expect(pin.parameter_names).to eq(%w[bar baz])
  end

  it "includes param tags in documentation" do
    comments = %(
      @param one [First] description1
      @param two [Second] description2
    )
    # pin = source.pins.select{|pin| pin.path == 'Foo#bar'}.first
    pin = described_class.new(comments: comments)
    expect(pin.documentation).to include("one")
    expect(pin.documentation).to include("[First]")
    expect(pin.documentation).to include("description1")
    expect(pin.documentation).to include("two")
    expect(pin.documentation).to include("[Second]")
    expect(pin.documentation).to include("description2")
  end

  it "detects return types from tags" do
    pin = described_class.new(comments: "@return [Hash]")
    expect(pin.return_type.tag).to eq("Hash")
  end

  it "ignores malformed return tags" do
    pin = described_class.new(name: "bar", comments: "@return [Array<String")
    expect(pin.return_type).to be_undefined
  end

  it "does not merge with changes in parameters" do
    # @todo Method pin parameters are pins now
    pin1 = described_class.new(name: "bar", parameters: ["one", "two"])
    pin2 = described_class.new(name: "bar", parameters: ["three"])
    expect(pin1.nearly?(pin2)).to be(false)
  end

  it "adds param tags to documentation" do
    # @todo Method pin parameters are pins now
    pin = described_class.new(name: "bar", comments: "@param one [String]", parameters: ["args"])
    expect(pin.documentation).to include("one", "[String]")
  end

  it "infers return types from reference tags" do
    source = Lunargraph::Source.load_string(%(
      class Foo1
        # @return [Hash]
        def bar; end
      end

      class Foo2
        # @return (see Foo1#bar)
        def baz; end
      end
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    pin = api_map.get_path_pins("Foo2#baz").first
    type = pin.typify(api_map)
    expect(type.tag).to eq("Hash")
  end

  it "infers return types from relative reference tags" do
    source = Lunargraph::Source.load_string(%(
      module Container
        class Foo1
          # @return [Hash]
          def bar; end
        end

        class Foo2
          # @return (see Foo1#bar)
          def baz; end
        end
      end
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    pin = api_map.get_path_pins("Container::Foo2#baz").first
    type = pin.typify(api_map)
    expect(type.tag).to eq("Hash")
  end

  it "infers return types from method reference tags" do
    source = Lunargraph::Source.load_string(%(
      class Foo
        # @return [Hash]
        def bar; end
        # @return (see #bar)
        def baz; end
      end
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    pin = api_map.get_path_pins("Foo#baz").first
    type = pin.typify(api_map)
    expect(type.tag).to eq("Hash")
  end

  it "infers return types from top-level reference tags" do
    source = Lunargraph::Source.load_string(%(
      class Other
        # @return [Hash]
        def origin; end
      end
      class Foo
        # (see Other#origin)
        def bar; end
      end
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    pin = api_map.get_path_pins("Foo#bar").first
    type = pin.typify(api_map)
    expect(type.tag).to eq("Hash")
  end

  it "typifies Booleans" do
    pin = described_class.new(name: "foo", comments: "@return [Boolean]", scope: :instance)
    api_map = Lunargraph::ApiMap.new
    type = pin.typify(api_map)
    expect(type.tag).to eq("Boolean")
  end

  it "strips prefixes from parameter names" do
    # @todo Method pin parameters are pins now
    # pin = Lunargraph::Pin::Method.new(args: ['foo', '*bar', '&block'])
    # expect(pin.parameter_names).to eq(['foo', 'bar', 'block'])
  end

  it "does not include yielded blocks in return nodes" do
    source = Lunargraph::Source.load_string(%(
      class Foo
        def bar
          [].select{|p| Hash.new}
        end
      end
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    pin = api_map.get_path_pins("Foo#bar").first
    type = pin.probe(api_map)
    expect(type.tag).to eq("Array")
  end

  it "processes overload tags" do
    pin = described_class.new(name: "foo", comments: %<
@overload foo(bar)
  @param bar [Integer]
  @return [String]
    >)
    expect(pin.overloads.length).to eq(1)
    overload = pin.overloads.first
    expect(overload.parameters.first.return_type.tag).to eq("Integer")
    expect(overload.return_type.tag).to eq("String")
  end

  it "processes overload tags with restargs" do
    pin = described_class.new(name: "foo", comments: %<
@overload foo(*bar)
@overload foo(**bar)
    >)
    expect(pin.overloads.length).to eq(2)
    restarg_overload = pin.overloads.first
    kwrestarg_overload = pin.overloads.last
    expect(restarg_overload.parameters.first.decl).to eq(:restarg)
    expect(kwrestarg_overload.parameters.first.decl).to eq(:kwrestarg)
  end

  it "infers from nil return nodes" do
    source = Lunargraph::Source.load_string(%(
      class Foo
        def bar
          if baz
            1
          end
        end
      end
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    pin = api_map.get_path_pins("Foo#bar").first
    type = pin.probe(api_map)
    expect(type.to_s).to eq("Integer, nil")
  end

  it "infers from chains" do
    source = Lunargraph::Source.load_string(%(
      class Foo
        def bar
          1 == 2
        end
      end
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    pin = api_map.get_path_pins("Foo#bar").first
    type = pin.probe(api_map)
    expect(type.to_s).to eq("Boolean")
  end

  it "typifies from super methods" do
    source = Lunargraph::Source.load_string(%(
      class Sup
        # @return [String]
        def foobar; end
      end
      class Sub < Sup
        def foobar; end
      end
    ))
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    pin = api_map.get_path_pins("Sub#foobar").first
    type = pin.typify(api_map)
    expect(type.tag).to eq("String")
  end

  it "assumes interrogative methods are Boolean" do
    source = Lunargraph::Source.load_string(%(
      class Foo
        def bar?; end
      end
    ))
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    pin = api_map.get_path_pins("Foo#bar?").first
    # The return type is undefined without a @return tag
    expect(pin.return_type).to be_undefined
    # Typify infers Boolean
    type = pin.typify(api_map)
    expect(type.tag).to eq("Boolean")
  end

  it "supports multiple return tags" do
    pin = described_class.new(
      name: "foo",
      comments: %(
@return [String]
@return [Integer]
      )
    )
    expect(pin.return_type.to_s).to eq("String, Integer")
  end

  it "includes @return text in documentation" do
    pin = described_class.new(
      name: "foo",
      comments: %(
@return [String] the foo text string
      )
    )
    expect(pin.documentation).to include("the foo text string")
  end

  context "as attribute" do
    it "is a kind of attribute/property" do
      source = Lunargraph::Source.load_string(%(
        class Foo
          attr_reader :bar
        end
      ))
      map = Lunargraph::SourceMap.map(source)
      pin = map.pins.find { |p| p.is_a?(described_class) }
      expect(pin).to be_attribute
      expect(pin.completion_item_kind).to eq(Lunargraph::LanguageServer::CompletionItemKinds::PROPERTY)
      expect(pin.symbol_kind).to eq(Lunargraph::LanguageServer::SymbolKinds::PROPERTY)
    end

    it "uses return type tags" do
      pin = described_class.new(name: "bar", comments: "@return [File]", attribute: true)
      expect(pin.return_type.tag).to eq("File")
    end

    it "detects undefined types" do
      pin = described_class.new(name: "bar", attribute: true)
      expect(pin.return_type).to be_undefined
    end

    it "generates paths" do
      npin = Lunargraph::Pin::Namespace.new(name: "Foo", type: :class)
      ipin = described_class.new(closure: npin, name: "bar", attribute: true, scope: :instance)
      expect(ipin.path).to eq("Foo#bar")
      cpin = described_class.new(closure: npin, name: "bar", attribute: true, scope: :class)
      expect(cpin.path).to eq("Foo.bar")
    end

    it "handles invalid return type tags" do
      pin = described_class.new(name: "bar", comments: "@return [Array<]", attribute: true)
      expect(pin.return_type).to be_undefined
    end

    it "infers untagged types from instance variables" do
      source = Lunargraph::Source.load_string(%(
        class Foo
          attr_reader :bar
          attr_writer :bar
          def initialize
            @bar = String.new
          end
        end
      ))
      api_map = Lunargraph::ApiMap.new
      api_map.map source
      pin = api_map.get_path_pins("Foo#bar").first
      expect(pin.typify(api_map)).to be_undefined
      expect(pin.probe(api_map).tag).to eq("String")
      pin = api_map.get_path_pins("Foo#bar=").first
      expect(pin.typify(api_map)).to be_undefined
      expect(pin.probe(api_map).tag).to eq("String")
    end
  end
end
