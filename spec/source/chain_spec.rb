describe Lunargraph::Source::Chain do
  it "gets empty definitions for undefined links" do
    chain = described_class.new([Lunargraph::Source::Chain::Link.new])
    expect(chain.define(nil, nil, nil)).to be_empty
  end

  it "infers undefined types for undefined links" do
    chain = described_class.new([Lunargraph::Source::Chain::Link.new])
    expect(chain.infer(nil, nil, nil)).to be_undefined
  end

  it "calls itself undefined if any of its links are undefined" do
    chain = described_class.new([Lunargraph::Source::Chain::Link.new])
    expect(chain).to be_undefined
  end

  it "returns undefined bases for single links" do
    chain = described_class.new([Lunargraph::Source::Chain::Link.new])
    expect(chain.base).to be_undefined
  end

  it "defines constants from core classes" do
    api_map = Lunargraph::ApiMap.new
    chain = described_class.new([Lunargraph::Source::Chain::Constant.new("String")])
    pins = chain.define(api_map, Lunargraph::Pin::ROOT_PIN, [])
    expect(pins.first).to be_a(Lunargraph::Pin::Namespace)
    expect(pins.first.path).to eq("String")
  end

  it "infers types from core classes" do
    api_map = Lunargraph::ApiMap.new
    chain = described_class.new([Lunargraph::Source::Chain::Constant.new("String")])
    type = chain.infer(api_map, Lunargraph::Pin::ROOT_PIN, [])
    expect(type.namespace).to eq("String")
    expect(type.scope).to eq(:class)
  end

  it "infers types from core methods" do
    api_map = Lunargraph::ApiMap.new
    chain = described_class.new([Lunargraph::Source::Chain::Constant.new("String"), Lunargraph::Source::Chain::Call.new("new")])
    type = chain.infer(api_map, Lunargraph::Pin::ROOT_PIN, [])
    expect(type.namespace).to eq("String")
    expect(type.scope).to eq(:instance)
  end

  it "recognizes literals" do
    chain = described_class.new([Lunargraph::Source::Chain::Literal.new("String")])
    expect(chain.literal?).to be(true)
  end

  it "recognizes constants" do
    chain = described_class.new([Lunargraph::Source::Chain::Constant.new("String")])
    expect(chain.constant?).to be(true)
  end

  it "recognizes unfinished constants" do
    chain = described_class.new([Lunargraph::Source::Chain::Constant.new("String"), Lunargraph::Source::Chain::Constant.new("<undefined>")])
    expect(chain.constant?).to be(true)
    expect(chain.base.constant?).to be(true)
    expect(chain.undefined?).to be(true)
    expect(chain.base.undefined?).to be(false)
  end

  it "infers types from new subclass calls without a subclass initialize method" do
    code = %(
      class Sup
        def initialize; end
        def meth; end
      end
      class Sub < Sup
        def meth; end
      end
    )
    map = Lunargraph::SourceMap.load_string(code)
    api_map = Lunargraph::ApiMap.new
    api_map.index map.pins
    sig = Lunargraph::Source.load_string("Sub.new")
    chain = Lunargraph::Source::SourceChainer.chain(sig, Lunargraph::Position.new(0, 5))
    type = chain.infer(api_map, Lunargraph::Pin::ROOT_PIN, [])
    expect(type.name).to eq("Sub")
  end

  it "follows constant chains" do
    source = Lunargraph::Source.load_string(%(
      module Mixin; end
      module Container
        class Foo; end
      end
      Container::Foo::Mixin
    ))
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    chain = Lunargraph::Source::SourceChainer.chain(source, Lunargraph::Position.new(5, 23))
    pins = chain.define(api_map, Lunargraph::Pin::ROOT_PIN, [])
    expect(pins).to be_empty
  end

  it "rebases inner constants chains" do
    source = Lunargraph::Source.load_string(%(
      class Foo
        class Bar; end
        ::Foo::Bar
      end
    ))
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    chain = Lunargraph::Source::SourceChainer.chain(source, Lunargraph::Position.new(3, 16))
    pins = chain.define(api_map, Lunargraph::Pin::ProxyType.new(closure: Lunargraph::Pin::Namespace.new(name: "Foo"), return_type: Lunargraph::ComplexType.parse("Class<Foo>")), [])
    expect(pins.first.path).to eq("Foo::Bar")
  end

  it "resolves relative constant paths" do
    source = Lunargraph::Source.load_string(%(
      class Foo
        class Bar
          class Baz; end
        end
        module Other
          Bar::Baz
        end
      end
    ))
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    chain = Lunargraph::Source::SourceChainer.chain(source, Lunargraph::Position.new(6, 16))
    pins = chain.define(api_map, Lunargraph::Pin::ProxyType.anonymous(Lunargraph::ComplexType.parse("Class<Foo::Other>")), [])
    expect(pins.first.path).to eq("Foo::Bar::Baz")
  end

  it "avoids recursive variable assignments" do
    source = Lunargraph::Source.load_string(%(
      @foo = @bar
      @bar = @foo.quz
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    chain = Lunargraph::Source::SourceChainer.chain(source, Lunargraph::Position.new(2, 18))
    expect {
      chain.define(api_map, Lunargraph::Pin::ROOT_PIN, [])
    }.not_to raise_error
  end

  it "matches constants on complete symbols" do
    source = Lunargraph::Source.load_string(%(
      class Correct; end
      class NotCorrect; end
      Correct
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    chain = Lunargraph::Source::SourceChainer.chain(source, Lunargraph::Position.new(3, 6))
    result = chain.define(api_map, Lunargraph::Pin::ROOT_PIN, [])
    expect(result.map(&:path)).to eq(["Correct"])
  end

  it "infers booleans from or-nodes passed to !" do
    source = Lunargraph::Source.load_string(%(
      !([].include?('.') || [].include?('#'))
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    chain = Lunargraph::Parser.chain(source.node, source.filename)
    type = chain.infer(api_map, api_map.pins.first, [])
    expect(type.tag).to eq("Boolean")
  end

  it "infers last type from and-nodes" do
    source = Lunargraph::Source.load_string(%(
      [] && ''
    ))
    api_map = Lunargraph::ApiMap.new
    chain = Lunargraph::Parser.chain(source.node)
    type = chain.infer(api_map, Lunargraph::Pin::ROOT_PIN, [])
    expect(type.to_s).to eq("String")
  end

  it "infers multiple types from or-nodes" do
    source = Lunargraph::Source.load_string(%(
      [] || ''
    ))
    api_map = Lunargraph::ApiMap.new
    chain = Lunargraph::Parser.chain(source.node)
    type = chain.infer(api_map, Lunargraph::Pin::ROOT_PIN, [])
    expect(type.to_s).to eq("Array, String")
  end

  it "infers Procs from block-pass nodes" do
    source = Lunargraph::Source.load_string(%(
      x = []
      x.map(&:foo)
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    node = source.node_at(2, 12)
    chain = Lunargraph::Parser.chain(node, "test.rb")
    pin = chain.define(api_map, Lunargraph::Pin::ROOT_PIN, []).first
    expect(pin.return_type.tag).to eq("Proc")
    type = chain.infer(api_map, Lunargraph::Pin::ROOT_PIN, [])
    expect(type.tag).to eq("Proc")
  end

  it "infers Boolean from true" do
    source = Lunargraph::Source.load_string(%(
      @x = true
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    node = source.node_at(1, 6)
    # chain = Lunargraph::Source::NodeChainer.chain(node, 'test.rb')
    chain = Lunargraph::Parser.chain(node, "test.rb")
    type = chain.infer(api_map, Lunargraph::Pin::ROOT_PIN, [])
    expect(type.tag).to eq("Boolean")
  end

  it "infers self from Object#freeze" do
    source = Lunargraph::Source.load_string(%(
      Array.new.freeze
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    node = source.node_at(1, 16)
    chain = Lunargraph::Parser.chain(node, "test.rb")
    type = chain.infer(api_map, Lunargraph::Pin::ROOT_PIN, [])
    expect(type.tag).to eq("Array")
  end

  it "infers the nearest constants first" do
    source = Lunargraph::Source.load_string(%(
      module Outer
        class String; end
      end
      module Outer
        module Inner
          def self.outer_string
            String
          end
        end
      end
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    closure = api_map.get_path_pins("Outer::Inner").first

    outer_node = api_map.get_path_pins("Outer::Inner.outer_string").first.send(:method_body_node)
    outer_chain = Lunargraph::Parser.chain(outer_node)
    outer_type = outer_chain.infer(api_map, closure, [])
    expect(outer_type.tag).to eq("Class<Outer::String>")
  end

  it "infers rooted constants" do
    source = Lunargraph::Source.load_string(%(
      module Outer
        class String; end
      end
      module Outer
        module Inner
          def self.core_string
            ::String
          end
        end
      end
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    closure = api_map.get_path_pins("Outer::Inner").first

    core_node = api_map.get_path_pins("Outer::Inner.core_string").first.send(:method_body_node)
    core_chain = Lunargraph::Parser.chain(core_node)
    core_type = core_chain.infer(api_map, closure, [])
    expect(core_type.tag).to eq("Class<String>")
  end

  it "infers String from interpolated strings" do
    source = Lunargraph::Source.load_string(%("#{Object}"), "test.rb")
    node = source.node
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    chain = Lunargraph::Parser.chain(node)
    type = chain.infer(api_map, Lunargraph::Pin::ROOT_PIN, [])
    expect(type.tag).to eq("String")
  end

  it "infers namespaces from constant aliases" do
    source = Lunargraph::Source.load_string(%(
      class Foo
        class Bar; end
      end
      Alias = Foo
      Alias::Bar.new
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    node = source.node_at(5, 17)
    chain = Lunargraph::Parser.chain(node, "test.rb")
    type = chain.infer(api_map, Lunargraph::Pin::ROOT_PIN, [])
    expect(type.tag).to eq("Foo::Bar")
  end

  it "detects blocks in multiple calls" do
    source = Lunargraph::Source.load_string(%(
      foo { |x| x }.bar { |y| y }
    ))
    chain = Lunargraph::Parser.chain(source.node)
    expect(chain.links.length).to eq(2)
    expect(chain.links[0]).to be_with_block
    expect(chain.links[1]).to be_with_block
  end

  it "infers instance variables from multiple assignments" do
    source = Lunargraph::Source.load_string(%(
      def foo
        @foo = nil
        @foo = 'foo'
      end
    ))
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    pin = api_map.get_path_pins("#foo").first
    type = pin.probe(api_map)
    expect(type.tag).to eq("String")
  end

  it "recognizes nil safe navigation" do
    source = Lunargraph::Source.load_string(%(
      String.new&.strip
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new.map(source)
    chain = Lunargraph::Source::SourceChainer.chain(source, Lunargraph::Position.new(1, 18))
    tag = chain.infer(api_map, Lunargraph::Pin::ROOT_PIN, [])
    expect(tag.to_s).to eq("String, nil")
  end

  it "infers Class<self> from Object#class" do
    source = Lunargraph::Source.load_string(%(
      String.new.class
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new.map(source)
    chain = Lunargraph::Source::SourceChainer.chain(source, Lunargraph::Position.new(1, 17))
    tag = chain.infer(api_map, Lunargraph::Pin::ROOT_PIN, [])
    expect(tag.to_s).to eq("Class<String>")
  end
end
