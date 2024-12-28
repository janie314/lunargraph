describe Lunargraph::LanguageServer::Host::MessageWorker do
  it "handle requests on queue" do
    host = double(Lunargraph::LanguageServer::Host)
    message = double
    expect(host).to receive(:receive).with(message).and_return(nil)

    worker = described_class.new(host)
    worker.queue(message)
    expect(worker.messages).to eq [message]
    worker.tick
  end
end
