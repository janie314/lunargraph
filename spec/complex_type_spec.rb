describe Lunargraph::ComplexType do
  let(:foo_bar_api_map) {
    api_map = Lunargraph::ApiMap.new
    source = Lunargraph::Source.load_string(%(
      module Foo
        class Bar
          # @return [Bar]
          def make_bar
          end
        end
      end
    ))
    api_map.map source
    api_map
  }

  it "parses a simple type" do
    types = described_class.parse "String"
    expect(types.length).to eq(1)
    expect(types.first.tag).to eq("String")
    expect(types.first.name).to eq("String")
    expect(types.first.subtypes).to be_empty
  end

  it "parses multiple types" do
    types = described_class.parse "String", "Integer"
    expect(types.length).to eq(2)
    expect(types[0].tag).to eq("String")
    expect(types[1].tag).to eq("Integer")
  end

  it "parses multiple types in a string" do
    types = described_class.parse "String, Integer"
    expect(types.length).to eq(2)
    expect(types[0].tag).to eq("String")
    expect(types[1].tag).to eq("Integer")
  end

  it "parses a subtype" do
    types = described_class.parse "Array<String>"
    expect(types.length).to eq(1)
    expect(types.first.tag).to eq("Array<String>")
    expect(types.first.name).to eq("Array")
    expect(types.first.subtypes.length).to eq(1)
    expect(types.first.subtypes.first.name).to eq("String")
  end

  it "parses multiple subtypes" do
    types = described_class.parse "Hash<Symbol, String>"
    expect(types.length).to eq(1)
    expect(types.first.tag).to eq("Hash<Symbol, String>")
    expect(types.first.name).to eq("Hash")
    expect(types.first.subtypes.length).to eq(2)
    expect(types.first.subtypes[0].name).to eq("Symbol")
    expect(types.first.subtypes[1].name).to eq("String")
  end

  it "detects namespace and scope for simple types" do
    types = described_class.parse "Class"
    expect(types.length).to eq(1)
    expect(types.first.namespace).to eq("Class")
    expect(types.first.scope).to eq(:instance)
  end

  it "detects namespace and scope for classes with subtypes" do
    types = described_class.parse "Class<String>"
    expect(types.length).to eq(1)
    expect(types.first.namespace).to eq("String")
    expect(types.first.scope).to eq(:class)
  end

  it "detects namespace and scope for modules with subtypes" do
    types = described_class.parse "Module<Foo>"
    expect(types.length).to eq(1)
    expect(types.first.namespace).to eq("Foo")
    expect(types.first.scope).to eq(:class)
  end

  it "identifies duck types" do
    types = described_class.parse("#method")
    expect(types.length).to eq(1)
    expect(types.first.namespace).to eq("Object")
    expect(types.first.scope).to eq(:instance)
    expect(types.first.duck_type?).to be(true)
  end

  it "identifies nil types" do
    %w[nil Nil NIL].each do |t|
      types = described_class.parse(t)
      expect(types.length).to eq(1)
      expect(types.first.namespace).to eq("NilClass")
      expect(types.first.scope).to eq(:instance)
      expect(types.first.nil_type?).to be(true)
    end
  end

  it "identifies parametrized types" do
    types = described_class.parse("Array<String>, Hash{String => Symbol}, Array(String, Integer)")
    expect(types.all?(&:parameters?)).to be(true)
  end

  it "identifies list parameters" do
    types = described_class.parse("Array<String, Symbol>")
    expect(types.first.list_parameters?).to be(true)
  end

  it "identifies hash parameters" do
    types = described_class.parse("Hash{String => Integer}")
    expect(types.length).to eq(1)
    expect(types.first.hash_parameters?).to be(true)
    expect(types.first.tag).to eq("Hash{String => Integer}")
    expect(types.first.namespace).to eq("Hash")
    expect(types.first.substring).to eq("{String => Integer}")
    expect(types.first.key_types.map(&:name)).to eq(["String"])
    expect(types.first.value_types.map(&:name)).to eq(["Integer"])
  end

  it "identifies fixed parameters" do
    types = described_class.parse("Array(String, Symbol)")
    expect(types.first.fixed_parameters?).to be(true)
    expect(types.first.subtypes.map(&:namespace)).to eq(["String", "Symbol"])
  end

  it "raises ComplexTypeError for unmatched brackets" do
    expect {
      described_class.parse("Array<String")
    }.to raise_error(Lunargraph::ComplexTypeError)
    expect {
      described_class.parse("Array{String")
    }.to raise_error(Lunargraph::ComplexTypeError)
    expect {
      described_class.parse("Array<String>>")
    }.to raise_error(Lunargraph::ComplexTypeError)
    expect {
      described_class.parse("Array{String}}")
    }.to raise_error(Lunargraph::ComplexTypeError)
    expect {
      described_class.parse("Array(String, Integer")
    }.to raise_error(Lunargraph::ComplexTypeError)
    expect {
      described_class.parse("Array(String, Integer))")
    }.to raise_error(Lunargraph::ComplexTypeError)
  end

  it "raises ComplexTypeError for hash parameters without key => value syntax" do
    expect {
      described_class.parse("Hash{Foo}")
    }.to raise_error(Lunargraph::ComplexTypeError)
    expect {
      described_class.parse("Hash{Foo, Bar}")
    }.to raise_error(Lunargraph::ComplexTypeError)
  end

  it "parses multiple key/value types in hash parameters" do
    types = described_class.parse("Hash{String, Symbol => Integer, BigDecimal}")
    expect(types.length).to eq(1)
    type = types.first
    expect(type.hash_parameters?).to be(true)
    expect(type.key_types.map(&:name)).to eq(["String", "Symbol"])
    expect(type.value_types.map(&:name)).to eq(["Integer", "BigDecimal"])
  end

  it "parses recursive subtypes" do
    types = described_class.parse("Array<Hash{String => Integer}>")
    expect(types.length).to eq(1)
    expect(types.first.namespace).to eq("Array")
    expect(types.first.substring).to eq("<Hash{String => Integer}>")
    expect(types.first.subtypes.length).to eq(1)
    expect(types.first.subtypes.first.namespace).to eq("Hash")
    expect(types.first.subtypes.first.substring).to eq("{String => Integer}")
    expect(types.first.subtypes.first.key_types.map(&:namespace)).to eq(["String"])
    expect(types.first.subtypes.first.value_types.map(&:namespace)).to eq(["Integer"])
  end

  it "qualifies types with list parameters" do
    original = described_class.parse("Class<Bar>").first
    qualified = original.qualify(foo_bar_api_map, "Foo")
    expect(qualified.tag).to eq("Class<Foo::Bar>")
  end

  it "qualifies types with fixed parameters" do
    original = described_class.parse("Array(String, Bar)").first
    qualified = original.qualify(foo_bar_api_map, "Foo")
    expect(qualified.tag).to eq("Array(String, Foo::Bar)")
  end

  it "qualifies types with hash parameters" do
    original = described_class.parse("Hash{String => Bar}").first
    qualified = original.qualify(foo_bar_api_map, "Foo")
    expect(qualified.tag).to eq("Hash{String => Foo::Bar}")
  end

  it "returns string representations of the entire type array" do
    type = described_class.parse("String", "Array<String>")
    expect(type.to_s).to eq("String, Array<String>")
  end

  it "returns the first type when multiple were parsed" do
    type = described_class.parse("String, Array<String>")
    expect(type.tag).to eq("String")
  end

  it "raises NoMethodError for missing methods" do
    type = described_class.parse("String")
    expect { type.undefined_method }.to raise_error(NoMethodError)
  end

  it "typifies Booleans" do
    api_map = double(Lunargraph::ApiMap, qualify: nil)
    type = described_class.parse("Boolean")
    qualified = type.qualify(api_map)
    expect(qualified.tag).to eq("Boolean")
  end

  it "returns undefined for unqualified types" do
    api_map = double(Lunargraph::ApiMap, qualify: nil)
    type = described_class.parse("UndefinedClass")
    qualified = type.qualify(api_map)
    expect(qualified).to be_undefined
  end

  it "reports selfy types" do
    type = described_class.parse("self")
    expect(type).to be_selfy
  end

  it "reports selfy parameter types" do
    type = described_class.parse("Class<self>")
    expect(type).to be_selfy
  end

  it "resolves self keywords in types" do
    selfy = described_class.parse("self")
    type = selfy.self_to("Foo")
    expect(type.tag).to eq("Foo")
  end

  it "resolves self keywords in parameter types" do
    selfy = described_class.parse("Array<self>")
    type = selfy.self_to("Foo")
    expect(type.tag).to eq("Array<Foo>")
  end

  it "resolves self keywords in hash parameter types" do
    selfy = described_class.parse("Hash{String => self}")
    type = selfy.self_to("Foo")
    expect(type.tag).to eq("Hash{String => Foo}")
  end

  it "resolves self keywords in ordered array types" do
    selfy = described_class.parse("Array<(String, Symbol, self)>")
    type = selfy.self_to("Foo")
    expect(type.tag).to eq("Array<(String, Symbol, Foo)>")
  end

  it "qualifies special types" do
    api_map = Lunargraph::ApiMap.new
    type = described_class.parse("nil")
    qual = type.qualify(api_map)
    expect(qual.tag).to eq("nil")
  end

  it "parses a complex subtype" do
    type = described_class.parse("Array<self>").self_to("Foo<String>")
    expect(type.tag).to eq("Array<Foo<String>>")
  end

  it "recognizes param types" do
    type = described_class.parse("param<Variable>")
    expect(type).to be_parameterized
  end

  it "recognizes parameterized parameters" do
    type = described_class.parse("Object<param<Variable>>")
    expect(type).to be_parameterized
  end
end
