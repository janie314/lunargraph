# frozen_string_literal: true

module Lunargraph
  module Convention
    class Gemspec < Base
      def local source_map
        return EMPTY_ENVIRON unless File.basename(source_map.filename).end_with?('.gemspec')
        @local ||= Environ.new(
          requires: ['rubygems'],
          pins: [
            Lunargraph::Pin::Reference::Override.from_comment(
              'Gem::Specification.new',
              %(
@yieldparam [self]
              )
            )
          ]
        )
      end
    end
  end
end
