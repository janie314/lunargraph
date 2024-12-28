# frozen_string_literal: true

module Lunargraph
  module Convention
    class Gemfile < Base
      def local source_map
        return EMPTY_ENVIRON unless File.basename(source_map.filename) == 'Gemfile'
        @local ||= Environ.new(
          requires: ['bundler'],
          domains: ['Bundler::Dsl']
        )
      end
    end
  end
end
