describe Lunargraph::LanguageServer::Message::Extended::CheckGemVersion do
  before do
    version = double(:GemVersion, version: Gem::Version.new("1.0.0"))
    described_class.fetcher = double(:fetcher, search_for_dependency: [version])
  end

  after do
    described_class.fetcher = nil
  end

  it "checks the gem source" do
    host = Lunargraph::LanguageServer::Host.new
    message = described_class.new(host, {})
    expect { message.process }.not_to raise_error
  end

  it "performs a verbose check" do
    host = Lunargraph::LanguageServer::Host.new
    message = described_class.new(host, { "params" => { "verbose" => true } })
    expect { message.process }.not_to raise_error
  end

  it "detects available updates" do
    host = Lunargraph::LanguageServer::Host.new
    message = described_class.new(host, {}, current: Gem::Version.new("0.0.1"))
    expect { message.process }.not_to raise_error
  end

  it "performs a verbose check with an available update" do
    host = Lunargraph::LanguageServer::Host.new
    message = described_class.new(host, { "params" => { "verbose" => true } }, current: Gem::Version.new("0.0.1"))
    expect { message.process }.not_to raise_error
  end

  it "responds to update actions" do
    host = Lunargraph::LanguageServer::Host.new
    message = described_class.new(host, {}, current: Gem::Version.new("0.0.1"))
    message.process
    response = nil
    reader = Lunargraph::LanguageServer::Transport::DataReader.new
    reader.set_message_handler do |data|
      response = data
    end
    reader.receive host.flush
    expect {
      action = {
        "id" => response["id"],
        "result" => response["params"]["actions"].first
      }
      host.receive action
    }.not_to raise_error
  end

  it "uses bundler" do
    host = Lunargraph::LanguageServer::Host.new
    host.configure({"useBundler" => true})
    message = described_class.new(host, {}, current: Gem::Version.new("0.0.1"))
    message.process
    response = nil
    reader = Lunargraph::LanguageServer::Transport::DataReader.new
    reader.set_message_handler do |data|
      response = data
    end
    reader.receive host.flush
    expect {
      action = {
        "id" => response["id"],
        "result" => response["params"]["actions"].first
      }
      host.receive action
    }.not_to raise_error
  end
end
