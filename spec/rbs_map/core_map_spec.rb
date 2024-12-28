describe Lunargraph::RbsMap::CoreMap do
  it "maps core Errno classes" do
    map = described_class.new
    store = Lunargraph::ApiMap::Store.new(map.pins)
    Errno.constants.each do |const|
      pin = store.get_path_pins("Errno::#{const}").first
      expect(pin).to be_a(Lunargraph::Pin::Namespace)
      superclass = store.get_superclass(pin.path)
      expect(superclass).to eq("SystemCallError")
    end
  end
end
