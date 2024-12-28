require "tmpdir"
require "fileutils"

describe Lunargraph::Documentor do
  # @todo Skipping Bundler-related tests on JRuby
  next if RUBY_PLATFORM == "java"

  it "returns gemsets for directories with bundles" do
    Dir.mktmpdir do |tmp|
      FileUtils.cp_r "spec/fixtures/workspace-with-gemfile", tmp
      gemset = described_class.specs_from_bundle("#{tmp}/workspace-with-gemfile")
      expect(gemset.keys).to eq(["backport", "bundler"])
    end
  end

  it "raises errors for directories without bundles" do
    Dir.mktmpdir do |tmp|
      expect {
        described_class.specs_from_bundle(tmp)
      }.to raise_error(Lunargraph::BundleNotFoundError)
    end
  end

  it "reports failures to document bundles" do
    Dir.mktmpdir do |tmp|
      result = described_class.new(tmp, rebuild: true).document
      expect(result).to be(false)
    end
  end
end
