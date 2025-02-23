describe Lunargraph::LanguageServer::Host::Dispatch do
  before :all do
    # @dispatch = Lunargraph::LanguageServer::Host::Dispatch
    @dispatch = Object.new
    @dispatch.extend described_class
  end

  after do
    @dispatch.libraries.clear
    @dispatch.sources.clear
  end

  it "finds an explicit library" do
    @dispatch.libraries.push Lunargraph::Library.load("*")
    src = @dispatch.sources.open("file:///file.rb", "a=b", 0)
    @dispatch.libraries.first.merge src
    lib = @dispatch.library_for("file:///file.rb")
    expect(lib).to be(@dispatch.libraries.first)
  end

  it "finds an implicit library" do
    dir = File.realpath(File.join("spec", "fixtures", "workspace"))
    file = File.join(dir, "new.rb")
    uri = Lunargraph::LanguageServer::UriHelpers.file_to_uri(file)
    @dispatch.libraries.push Lunargraph::Library.load(dir)
    @dispatch.sources.open uri, "a=b", 0
    lib = @dispatch.library_for(uri)
    expect(lib).to be(@dispatch.libraries.first)
  end

  it "finds a generic library" do
    dir = File.realpath(File.join("spec", "fixtures", "workspace"))
    file = "/external.rb"
    uri = Lunargraph::LanguageServer::UriHelpers.file_to_uri(file)
    @dispatch.libraries.push Lunargraph::Library.load(dir)
    @dispatch.sources.open uri, "a=b", 0
    lib = @dispatch.library_for(uri)
    expect(lib).to be(@dispatch.generic_library)
  end
end
