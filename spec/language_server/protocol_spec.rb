class Protocol
  attr_reader :response

  # @return [Lunargraph::LanguageServer::Host]
  attr_reader :host

  def initialize host
    @host = host
    @host.start
    @data_reader = Lunargraph::LanguageServer::Transport::DataReader.new
    @data_reader.set_message_handler do |message|
      @response = message
    end
    @message_id = 0
  end

  def request method, params
    @response = nil
    msg = {
      "id" => @message_id,
      "method" => method,
      "params" => params
    }
    @message_id += 1
    message = @host.receive msg
    message.send_response
    @data_reader.receive @host.flush
  end

  def stop
    @host.stop
  end
end

describe Protocol do
  before :all do
    @protocol = described_class.new(Lunargraph::LanguageServer::Host.new)
  end

  after :all do
    @protocol.stop
  end

  before do
    version = double(:GemVersion, version: Gem::Version.new("1.0.0"))
    Lunargraph::LanguageServer::Message::Extended::CheckGemVersion.fetcher = double(:fetcher, search_for_dependency: [version])
  end

  after do
    Lunargraph::LanguageServer::Message::Extended::CheckGemVersion.fetcher = nil
  end

  it "handles initialize" do
    @protocol.request "initialize", {
      "capabilities" => {
        "textDocument" => {
          "completion" => {
            "dynamicRegistration" => true
          },
          "hover" => {
            "dynamicRegistration" => false
          }
        }
      }
    }
    response = @protocol.response
    expect(response["result"].keys).to include("capabilities")
  end

  it "is not stopped after initialization" do
    expect(@protocol.host.stopped?).to be(false)
  end

  it "configured dynamic registration capabilities from initialize" do
    expect(@protocol.host.can_register?("textDocument/completion")).to be(true)
    expect(@protocol.host.can_register?("textDocument/hover")).to be(false)
    expect(@protocol.host.can_register?("workspace/symbol")).to be(false)
  end

  it "handles initialized" do
    @protocol.request "initialized", nil
    response = @protocol.response
    expect(response["error"]).to be_nil
  end

  it "configured default dynamic registration capabilities from initialized" do
    expect(@protocol.host.registered?("textDocument/completion")).to be(true)
  end

  it "handles textDocument/didOpen" do
    @protocol.request "textDocument/didOpen", {
      "textDocument" => {
        "uri" => "file:///file.rb",
        "text" => %(
          class Foo
            # bar method
            def bar baz
            end
          end
          foo = Foo.new
          String
          foo.bar()
          File.abs
        ),
        "version" => 0
      }
    }
    @protocol.response
    expect(@protocol.host.open?("file:///file.rb")).to be(true)
  end

  it "handles textDocument/documentHighlight" do
    @protocol.request "textDocument/documentHighlight", {
      "textDocument" => {
        "uri" => "file:///file.rb"
      },
      "position" => {
        "line" => 1,
        "character" => 17
      }
    }
    response = @protocol.response
    # Two references to Foo: the class definition and the Foo.new call
    expect(response["result"].length).to eq(2)
  end

  it "handles textDocument/didChange" do
    @protocol.request "textDocument/didChange", {
      "textDocument" => {
        "uri" => "file:///file.rb",
        "version" => 1
      },
      "contentChanges" => [
        {
          "range" => {
            "start" => {
              "line" => 7,
              "character" => 16
            },
            "end" => {
              "line" => 7,
              "character" => 16
            }
          },
          "text" => ";"
        }
      ]
    }
    @protocol.response
    # @todo What to expect?
  end

  it "handles textDocument/completion" do
    @protocol.request "textDocument/completion", {
      "textDocument" => {
        "uri" => "file:///file.rb"
      },
      "position" => {
        "line" => 8,
        "character" => 14
      }
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
    expect(response["result"]["items"].length > 0).to be(true)
  end

  it "handles completionItem/resolve" do
    # Reuse the response from textDocument/completion
    response = @protocol.response
    item = response["result"]["items"].find { |h| h["label"] == "bar" }
    @protocol.request "completionItem/resolve", item
    response = @protocol.response
    expect(response["result"]["documentation"]["value"]).to include("bar method")
  end

  it "suppresses FileNotFoundError in textDocument/completion" do
    @protocol.request "textDocument/completion", {
      "textDocument" => {
        "uri" => "file:///notfile.rb"
      },
      "position" => {
        "line" => 1,
        "character" => 1
      }
    }
    expect(@protocol.response["error"]).to be_nil
  end

  it "documents YARD pins" do
    @protocol.request "textDocument/completion", {
      "textDocument" => {
        "uri" => "file:///file.rb"
      },
      "position" => {
        "line" => 9,
        "character" => 18
      }
    }
    response = @protocol.response
    item = response["result"]["items"].find { |i| i["data"]["path"] == "File.absolute_path" }
    expect(item).not_to be_nil
    @protocol.request "completionItem/resolve", item
    response = @protocol.response
    expect(response["result"]["documentation"]).not_to be_empty
  end

  it "handles workspace/symbol" do
    @protocol.request "workspace/symbol", {
      "query" => "test"
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
  end

  it "handles textDocument/definition" do
    sleep 0.5 # HACK: Give the Host::Sources thread time to work
    @protocol.request "textDocument/definition", {
      "textDocument" => {
        "uri" => "file:///file.rb"
      },
      "position" => {
        "line" => 6,
        "character" => 17
      }
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
    expect(response["result"]).not_to be_empty
  end

  it "handles textDocument/definition on undefined symbols" do
    @protocol.request "textDocument/definition", {
      "textDocument" => {
        "uri" => "file:///file.rb"
      },
      "position" => {
        "line" => 5,
        "character" => 11
      }
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
    expect(response["result"]).to be_empty
  end

  it "handles textDocument/documentSymbol" do
    @protocol.request "textDocument/documentSymbol", {
      "textDocument" => {
        "uri" => "file:///file.rb"
      }
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
  end

  it "handles textDocument/hover" do
    @protocol.request "textDocument/hover", {
      "textDocument" => {
        "uri" => "file:///file.rb"
      },
      "position" => {
        "line" => 6,
        "character" => 17
      }
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
    # Given this request hovers over `Foo`, the result should not be empty
    expect(response["result"]["contents"]).not_to be_empty
  end

  it "suppresses FileNotFoundError in textDocument/hover" do
    @protocol.request "textDocument/hover", {
      "textDocument" => {
        "uri" => "file:///notfile.rb"
      },
      "position" => {
        "line" => 6,
        "character" => 17
      }
    }
    expect(@protocol.response["error"]).to be_nil
  end

  it "handles textDocument/signatureHelp" do
    @protocol.request "textDocument/signatureHelp", {
      "textDocument" => {
        "uri" => "file:///file.rb"
      },
      "position" => {
        "line" => 8,
        "character" => 18
      }
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
    expect(response["result"]["signatures"]).not_to be_empty
  end

  it "handles workspace/symbol" do
    @protocol.request "workspace/symbol", {
      "query" => "Foo"
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
    expect(response["result"]).not_to be_empty
  end

  it "handles textDocument/references for namespaces" do
    @protocol.request "textDocument/references", {
      "textDocument" => {
        "uri" => "file:///file.rb"
      },
      "position" => {
        "line" => 7,
        "character" => 15
      }
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
    expect(response["result"]).not_to be_empty
  end

  it "handles textDocument/references for methods" do
    @protocol.request "textDocument/references", {
      "textDocument" => {
        "uri" => "file:///file.rb"
      },
      "position" => {
        "line" => 8,
        "character" => 15
      }
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
    expect(response["result"]).not_to be_empty
  end

  it "handles textDocument/rename" do
    @protocol.request "textDocument/rename", {
      "textDocument" => {
        "uri" => "file:///file.rb"
      },
      "position" => {
        "line" => 7,
        "character" => 15
      },
      "newName" => "new_name"
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
    expect(response["result"]["changes"]["file:///file.rb"]).to be_a(Array)
  end

  it "handles textDocument/prepareRename" do
    @protocol.request "textDocument/prepareRename", {
      "textDocument" => {
        "uri" => "file:///file.rb"
      },
      "position" => {
        "line" => 7,
        "character" => 15
      },
      "newName" => "new_name"
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
    expect(response["result"]).to be_a(Hash)
  end

  it "handles textDocument/foldingRange" do
    @protocol.request "textDocument/foldingRange", {
      "textDocument" => {
        "uri" => "file:///file.rb"
      }
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
    expect(response["result"].length).not_to be_zero
  end

  it "handles textDocument/didClose" do
    @protocol.request "textDocument/didClose", {
      "textDocument" => {
        "uri" => "file:///file.rb"
      }
    }
    @protocol.response
    expect(@protocol.host.open?("file:///file.rb")).to be(false)
  end

  it "handles $/lunargraph/search" do
    @protocol.request "$/lunargraph/search", {
      "query" => "Foo#bar"
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
    expect(response["result"]["content"]).not_to be_empty
  end

  it "handles $/lunargraph/document" do
    @protocol.request "$/lunargraph/document", {
      "query" => "String"
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
    expect(response["result"]["content"]).not_to be_empty
  end

  it "handles workspace/didChangeConfiguration" do
    @protocol.request "workspace/didChangeConfiguration", {
      "settings" => {
        "lunargraph" => {
          "autoformat" => false,
          "completion" => false
        }
      }
    }
    expect(@protocol.host.options["autoformat"]).to be(false)
    expect(@protocol.host.registered?("textDocument/completion")).to be(false)
  end

  it "handles $/lunargraph/checkGemVersion" do
    @protocol.request "$/lunargraph/checkGemVersion", { verbose: false }
    response = @protocol.response
    expect(response["error"]).to be_nil
    expect(response["result"]["installed"]).to be_a(String)
    expect(response["result"]["available"]).to be_a(String)
  end

  it "handles $/lunargraph/documentGems" do
    @protocol.request "$/lunargraph/documentGems", {}
    response = @protocol.response
    expect(response["error"]).to be_nil
  end

  it "handles textDocument/formatting" do
    @protocol.request "textDocument/didOpen", {
      "textDocument" => {
        "uri" => Lunargraph::LanguageServer::UriHelpers.file_to_uri(File.realpath("spec/fixtures/formattable.rb")),
        "text" => File.read("spec/fixtures/formattable.rb"),
        "version" => 1
      }
    }
    @protocol.request "textDocument/formatting", {
      "textDocument" => {
        "uri" => Lunargraph::LanguageServer::UriHelpers.file_to_uri(File.realpath("spec/fixtures/formattable.rb"))
      }
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
    expect(response["result"].first["newText"]).to be_a(String)
  end

  it "can format file without file extension" do
    @protocol.request "textDocument/didOpen", {
      "textDocument" => {
        "uri" => Lunargraph::LanguageServer::UriHelpers.file_to_uri(File.realpath("spec/fixtures/formattable")),
        "text" => File.read("spec/fixtures/formattable"),
        "version" => 1
      }
    }
    @protocol.request "textDocument/formatting", {
      "textDocument" => {
        "uri" => Lunargraph::LanguageServer::UriHelpers.file_to_uri(File.realpath("spec/fixtures/formattable"))
      }
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
    # @todo Rules for parenthesized parameters have apparently changed in RuboCop 0.89
    # expect(response['result'].first['newText']).to include('def barbaz(parameter); end')
  end

  it "handles MethodNotFound errors" do
    @protocol.request "notamethod", {}
    response = @protocol.response
    expect(response["error"]["code"]).to be(Lunargraph::LanguageServer::ErrorCodes::METHOD_NOT_FOUND)
  end

  it "handles didChangeWatchedFiles for created files" do
    @protocol.request "workspace/didChangeWatchedFiles", {
      "changes" => [
        {
          "type" => Lunargraph::LanguageServer::Message::Workspace::DidChangeWatchedFiles::CREATED,
          "uri" => "file:///watched-file.rb"
        }
      ]
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
  end

  it "handles didChangeWatchedFiles for changed files" do
    @protocol.request "workspace/didChangeWatchedFiles", {
      "changes" => [
        {
          "type" => Lunargraph::LanguageServer::Message::Workspace::DidChangeWatchedFiles::CHANGED,
          "uri" => "file:///watched-file.rb"
        }
      ]
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
  end

  it "handles didChangeWatchedFiles for deleted files" do
    @protocol.request "workspace/didChangeWatchedFiles", {
      "changes" => [
        {
          "type" => Lunargraph::LanguageServer::Message::Workspace::DidChangeWatchedFiles::DELETED,
          "uri" => "file:///watched-file.rb"
        }
      ]
    }
    response = @protocol.response
    expect(response["error"]).to be_nil
  end

  it "handles didChangeWatchedFiles for invalid change types" do
    @protocol.request "workspace/didChangeWatchedFiles", {
      "changes" => [
        {
          "type" => -99999,
          "uri" => "file:///watched-file.rb"
        }
      ]
    }
    response = @protocol.response
    expect(response["error"]).not_to be_nil
  end

  it "adds folders to the workspace" do
    dir = File.absolute_path("spec/fixtures/workspace_folders/folder1")
    uri = Lunargraph::LanguageServer::UriHelpers.file_to_uri(dir)
    @protocol.request "workspace/didChangeWorkspaceFolders", {
      "event" => {
        "added" => [
          {
            "uri" => uri,
            "name" => "folder1"
          }
        ],
        "removed" => []
      }
    }
    expect(@protocol.host.folders).to include(dir)
  end

  it "removes folders from the workspace" do
    dir = File.absolute_path("spec/fixtures/workspace_folders/folder1")
    uri = Lunargraph::LanguageServer::UriHelpers.file_to_uri(dir)
    @protocol.request "workspace/didChangeWorkspaceFolders", {
      "event" => {
        "added" => [],
        "removed" => [
          {
            "uri" => uri,
            "name" => "folder1"
          }
        ]
      }
    }
    expect(@protocol.host.folders).not_to include(dir)
  end

  it "handles $/cancelRequest" do
    expect {
      @protocol.request "$/cancelRequest", {
        "id" => 0
      }
    }.not_to raise_error
  end

  it "handles $/lunargraph/environment" do
    @protocol.request "$/lunargraph/environment", {}
    response = @protocol.response
    expect(response["result"]["content"]).not_to be_nil
  end

  it "handles shutdown" do
    @protocol.request "shutdown", {}
    response = @protocol.response
    expect(response["error"]).to be_nil
  end

  it "handles exit" do
    @protocol.request "exit", {}
    response = @protocol.response
    expect(response["error"]).to be_nil
    expect(@protocol.host.stopped?).to be(true)
  end
end
