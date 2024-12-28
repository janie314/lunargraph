describe Lunargraph::Diagnostics::RequireNotFound do
  before do
    @source = Lunargraph::Source.new(%(
      require 'rexml/document'
      require 'not_valid'
    ), "file.rb")

    @source_map = Lunargraph::SourceMap.map(@source)

    @api_map = Lunargraph::ApiMap.new
    @api_map.catalog Lunargraph::Bench.new(source_maps: [@source_map], external_requires: ["not_valid"])
  end

  it "reports unresolved requires" do
    reporter = described_class.new
    result = reporter.diagnose(@source, @api_map)
    expect(result.length).to eq(1)
  end
end
