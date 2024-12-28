describe Lunargraph::Parser::NodeProcessor do
  it "ignores bare private_constant calls" do
    node = Lunargraph::Parser.parse(%(
      class Foo
        private_constant
      end
    ))
    expect {
      described_class.process(node)
    }.not_to raise_error
  end

  it "orders optional args correctly" do
    node = Lunargraph::Parser.parse(%(
      def foo(bar = nil, baz = nil); end
    ))
    pins, = described_class.process(node)
    # Method pin is first pin after default namespace
    pin = pins[1]
    expect(pin.parameters.map(&:name)).to eq(%w[bar baz])
  end
end
