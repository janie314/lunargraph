describe Lunargraph::TypeChecker::Checks do
  it "validates simple core types" do
    api_map = Lunargraph::ApiMap.new
    exp = Lunargraph::ComplexType.parse("String")
    inf = Lunargraph::ComplexType.parse("String")
    match = described_class.types_match?(api_map, exp, inf)
    expect(match).to be(true)
  end

  it "invalidates simple core types" do
    api_map = Lunargraph::ApiMap.new
    exp = Lunargraph::ComplexType.parse("String")
    inf = Lunargraph::ComplexType.parse("Integer")
    match = described_class.types_match?(api_map, exp, inf)
    expect(match).to be(false)
  end

  it "validates expected superclasses" do
    source = Lunargraph::Source.load_string(%(
      class Sup; end
      class Sub < Sup; end
    ))
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    sup = Lunargraph::ComplexType.parse("Sup")
    sub = Lunargraph::ComplexType.parse("Sub")
    match = described_class.types_match?(api_map, sup, sub)
    expect(match).to be(true)
  end

  it "invalidates inferred superclasses (expected must be super)" do
    # @todo This test might be invalid. There are use cases where inheritance
    #   between inferred and expected classes should be acceptable in either
    #   direction.
    # source = Lunargraph::Source.load_string(%(
    #   class Sup; end
    #   class Sub < Sup; end
    # ))
    # api_map = Lunargraph::ApiMap.new
    # api_map.map source
    # sup = Lunargraph::ComplexType.parse('Sup')
    # sub = Lunargraph::ComplexType.parse('Sub')
    # match = Lunargraph::TypeChecker::Checks.types_match?(api_map, sub, sup)
    # expect(match).to be(false)
  end

  it "fuzzy matches arrays with parameters" do
    api_map = Lunargraph::ApiMap.new
    exp = Lunargraph::ComplexType.parse("Array")
    inf = Lunargraph::ComplexType.parse("Array<String>")
    match = described_class.types_match?(api_map, exp, inf)
    expect(match).to be(true)
  end

  it "fuzzy matches sets with parameters" do
    source = Lunargraph::Source.load_string("require 'set'")
    source_map = Lunargraph::SourceMap.map(source)
    api_map = Lunargraph::ApiMap.new
    api_map.catalog Lunargraph::Bench.new(source_maps: [source_map], external_requires: ["set"])
    exp = Lunargraph::ComplexType.parse("Set")
    inf = Lunargraph::ComplexType.parse("Set<String>")
    match = described_class.types_match?(api_map, exp, inf)
    expect(match).to be(true)
  end

  it "fuzzy matches hashes with parameters" do
    api_map = Lunargraph::ApiMap.new
    exp = Lunargraph::ComplexType.parse("Hash{ Symbol => String}")
    inf = Lunargraph::ComplexType.parse("Hash")
    match = described_class.types_match?(api_map, exp, inf)
    expect(match).to be(true)
  end

  it "matches multiple types" do
    api_map = Lunargraph::ApiMap.new
    exp = Lunargraph::ComplexType.parse("String, Integer")
    inf = Lunargraph::ComplexType.parse("String, Integer")
    match = described_class.types_match?(api_map, exp, inf)
    expect(match).to be(true)
  end

  it "matches multiple types out of order" do
    api_map = Lunargraph::ApiMap.new
    exp = Lunargraph::ComplexType.parse("String, Integer")
    inf = Lunargraph::ComplexType.parse("Integer, String")
    match = described_class.types_match?(api_map, exp, inf)
    expect(match).to be(true)
  end

  it "invalidates inferred types missing from expected" do
    api_map = Lunargraph::ApiMap.new
    exp = Lunargraph::ComplexType.parse("String")
    inf = Lunargraph::ComplexType.parse("String, Integer")
    match = described_class.types_match?(api_map, exp, inf)
    expect(match).to be(false)
  end

  it "matches nil" do
    api_map = Lunargraph::ApiMap.new
    exp = Lunargraph::ComplexType.parse("nil")
    inf = Lunargraph::ComplexType.parse("nil")
    match = described_class.types_match?(api_map, exp, inf)
    expect(match).to be(true)
  end

  it "validates classes with expected superclasses" do
    api_map = Lunargraph::ApiMap.new
    exp = Lunargraph::ComplexType.parse("Class<Object>")
    inf = Lunargraph::ComplexType.parse("Class<String>")
    match = described_class.types_match?(api_map, exp, inf)
    expect(match).to be(true)
  end

  it "validates parameterized classes with expected Class" do
    api_map = Lunargraph::ApiMap.new
    exp = Lunargraph::ComplexType.parse("Class<String>")
    inf = Lunargraph::ComplexType.parse("Class")
    match = described_class.types_match?(api_map, exp, inf)
    expect(match).to be(true)
  end

  it "validates inheritance in both directions" do
    source = Lunargraph::Source.load_string(%(
      class Sup; end
      class Sub < Sup; end
    ))
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    sup = Lunargraph::ComplexType.parse("Sup")
    sub = Lunargraph::ComplexType.parse("Sub")
    match = described_class.either_way?(api_map, sup, sub)
    expect(match).to be(true)
    match = described_class.either_way?(api_map, sub, sup)
    expect(match).to be(true)
  end

  it "invalidates inheritance in both directions" do
    api_map = Lunargraph::ApiMap.new
    sup = Lunargraph::ComplexType.parse("String")
    sub = Lunargraph::ComplexType.parse("Array")
    match = described_class.either_way?(api_map, sup, sub)
    expect(match).to be(false)
    match = described_class.either_way?(api_map, sub, sup)
    expect(match).to be(false)
  end
end
