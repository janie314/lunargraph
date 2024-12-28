# frozen_string_literal: true

require 'set'

module Lunargraph
  # Conventions provide a way to modify an ApiMap based on expectations about
  # one of its sources.
  #
  module Convention
    autoload :Base,    'lunargraph/convention/base'
    autoload :Gemfile, 'lunargraph/convention/gemfile'
    autoload :Rspec,   'lunargraph/convention/rspec'
    autoload :Gemspec, 'lunargraph/convention/gemspec'
    autoload :Rakefile, 'lunargraph/convention/rakefile'

    @@conventions = Set.new

    # @param convention [Class<Convention::Base>]
    # @return [void]
    def self.register convention
      @@conventions.add convention.new
    end

    # @param source_map [SourceMap]
    # @return [Environ]
    def self.for_local(source_map)
      result = Environ.new
      @@conventions.each do |conv|
        result.merge conv.local(source_map)
      end
      result
    end

    # @param yard_map [YardMap]
    # @return [Environ]
    def self.for_global(yard_map)
      result = Environ.new
      @@conventions.each do |conv|
        result.merge conv.global(yard_map)
      end
      result
    end

    register Gemfile
    register Gemspec
    register Rspec
    register Rakefile
  end
end
