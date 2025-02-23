describe Lunargraph::Pin::BaseVariable do
  it "checks assignments for equality" do
    smap = Lunargraph::SourceMap.load_string('foo = "foo"')
    pin1 = smap.locals.first
    smap = Lunargraph::SourceMap.load_string('foo = "foo"')
    pin2 = smap.locals.first
    expect(pin1).to eq(pin2)
    smap = Lunargraph::SourceMap.load_string('foo = "bar"')
    pin2 = smap.locals.first
    expect(pin1).not_to eq(pin2)
  end

  it "infers types from variable assignments with unparenthesized parameters" do
    source = Lunargraph::Source.load_string(%(
      class Container
        def initialize; end
      end
      cnt = Container.new param1, param2
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    pin = api_map.source_map("test.rb").locals.first
    type = pin.probe(api_map)
    expect(type.tag).to eq("Container")
  end

  it "infers from nil nodes without locations" do
    source = Lunargraph::Source.load_string(%(
      class Foo
        def bar
          @bar =
            if baz
              1
            end
        end
      end
    ), "test.rb")
    api_map = Lunargraph::ApiMap.new
    api_map.map source
    pin = api_map.get_instance_variable_pins("Foo").first
    type = pin.probe(api_map)
    expect(type.to_s).to eq("Integer, nil")
  end
end
