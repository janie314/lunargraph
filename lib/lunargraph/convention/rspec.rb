# frozen_string_literal: true

module Lunargraph
  module Convention
    class Rspec < Base
      def local source_map
        return EMPTY_ENVIRON unless /_spec\.rb$/.match?(File.basename(source_map.filename))
        @local ||= Environ.new(
          requires: ['rspec'],
          domains: ['RSpec::Matchers', 'RSpec::ExpectationGroups'],
          pins: [
            # This override is necessary due to an erroneous @return tag in
            # rspec's YARD documentation.
            # @todo The return types have been fixed (https://github.com/rspec/rspec-expectations/pull/1121)
            Lunargraph::Pin::Reference::Override.method_return('RSpec::Matchers#expect',
                                                               'RSpec::Expectations::ExpectationTarget')
          ].concat(extras)
        )
      end

      private

      def extras
        @@extras ||= SourceMap.load_string(%(
          def describe(*args); end
          def it(*args); end
        )).pins
      end
    end
  end
end
