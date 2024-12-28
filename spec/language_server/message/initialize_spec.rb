describe Lunargraph::LanguageServer::Message::Initialize do
  it "prepares workspace folders" do
    host = Lunargraph::LanguageServer::Host.new
    dir = File.realpath(File.join("spec", "fixtures", "workspace"))
    init = described_class.new(host, {
      "params" => {
        "capabilities" => {
          "workspace" => {
            "workspaceFolders" => true
          }
        },
        "workspaceFolders" => [
          {
            "uri" => Lunargraph::LanguageServer::UriHelpers.file_to_uri(dir),
            "name" => "workspace"
          }
        ]
      }
    })
    init.process
    expect(host.folders.length).to eq(1)
  end

  it "prepares rootUri as a workspace" do
    host = Lunargraph::LanguageServer::Host.new
    dir = File.realpath(File.join("spec", "fixtures", "workspace"))
    init = described_class.new(host, {
      "params" => {
        "capabilities" => {
          "workspace" => {
            "workspaceFolders" => true
          }
        },
        "rootUri" => Lunargraph::LanguageServer::UriHelpers.file_to_uri(dir)
      }
    })
    init.process
    expect(host.folders.length).to eq(1)
  end

  it "prepares rootPath as a workspace" do
    host = Lunargraph::LanguageServer::Host.new
    dir = File.realpath(File.join("spec", "fixtures", "workspace"))
    init = described_class.new(host, {
      "params" => {
        "capabilities" => {
          "workspace" => {
            "workspaceFolders" => true
          }
        },
        "rootPath" => dir
      }
    })
    init.process
    expect(host.folders.length).to eq(1)
  end
end
