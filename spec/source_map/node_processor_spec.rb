describe "Node processor (generic)" do
  it "maps arg parameters" do
    map = Lunargraph::SourceMap.load_string(%(
      class Foo
        def bar(arg); end
      end
    ))
    expect(map.locals.first.decl).to eq(:arg)
  end

  it "maps optarg parameters" do
    map = Lunargraph::SourceMap.load_string(%(
      class Foo
        def bar(arg = 0); end
      end
    ))
    expect(map.locals.first.decl).to eq(:optarg)
  end

  it "maps kwarg parameters" do
    map = Lunargraph::SourceMap.load_string(%(
      class Foo
        def bar(arg:); end
      end
    ))
    expect(map.locals.first.decl).to eq(:kwarg)
  end

  it "maps kwoptarg parameters" do
    map = Lunargraph::SourceMap.load_string(%(
      class Foo
        def bar(arg: 0); end
      end
    ))
    expect(map.locals.first.decl).to eq(:kwoptarg)
  end

  it "maps restarg parameters" do
    map = Lunargraph::SourceMap.load_string(%(
      class Foo
        def bar(*arg); end
      end
    ))
    expect(map.locals.first.decl).to eq(:restarg)
  end

  it "maps kwrestarg parameters" do
    map = Lunargraph::SourceMap.load_string(%(
      class Foo
        def bar(**arg); end
      end
    ))
    expect(map.locals.first.decl).to eq(:kwrestarg)
  end

  it "maps blockarg parameters" do
    map = Lunargraph::SourceMap.load_string(%(
      class Foo
        def bar(&arg); end
      end
    ))
    expect(map.locals.first.decl).to eq(:blockarg)
  end

  it "generates extend pins for modules included in class << self" do
    map = Lunargraph::SourceMap.load_string(%(
      module Extender
        def foo; end
      end

      class Example
        class << self
          include Extender
        end
      end
    ))
    ext = map.pins.find { |pin| pin.is_a?(Lunargraph::Pin::Reference::Extend) }
    expect(ext.name).to eq("Extender")
  end

  it "maps nested constant assignments" do
    map = Lunargraph::SourceMap.load_string(%(
      Foo = Class.new
      Foo::BAR = Object.new
    ))
    # @type [Lunargraph::Pin::Constant]
    pin = map.first_pin("Foo::BAR")
    expect(pin).to be_a(Lunargraph::Pin::Constant)
    expect(pin.assignment.to_sexp).to include(":Object")
    expect(pin.assignment.to_sexp).to include(":new")
  end
end
