# frozen_string_literal: true

require 'bundler'
require 'shellwords'

module Lunargraph
  class ApiMap
    module BundlerMethods
      module_function

      # @param directory [String]
      # @return [Hash]
      def require_from_bundle directory
        Lunargraph.logger.info 'Loading gems for bundler/require'
        Documentor.specs_from_bundle(directory)
      rescue BundleNotFoundError => e
        Lunargraph.logger.warn e.message
        {}
      end
    end
  end
end
