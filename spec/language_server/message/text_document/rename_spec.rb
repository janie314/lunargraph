describe Lunargraph::LanguageServer::Message::TextDocument::Rename do
  it "renames a symbol" do
    host = Lunargraph::LanguageServer::Host.new
    host.start
    host.open("file:///file.rb", %(
      class Foo
      end
      foo = Foo.new
    ), 1)
    rename = described_class.new(host, {
      "id" => 1,
      "method" => "textDocument/rename",
      "params" => {
        "textDocument" => {
          "uri" => "file:///file.rb"
        },
        "position" => {
          "line" => 1,
          "character" => 12
        },
        "newName" => "Bar"
      }
    })
    rename.process
    expect(rename.result[:changes]["file:///file.rb"].length).to eq(2)
  end
end
