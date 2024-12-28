# frozen_string_literal: true

module Lunargraph
  # The Diagnostics library provides reporters for analyzing problems in code
  # and providing the results to language server clients.
  #
  module Diagnostics
    autoload :Base,            'lunargraph/diagnostics/base'
    autoload :Severities,      'lunargraph/diagnostics/severities'
    autoload :Rubocop,         'lunargraph/diagnostics/rubocop'
    autoload :RubocopHelpers,  'lunargraph/diagnostics/rubocop_helpers'
    autoload :RequireNotFound, 'lunargraph/diagnostics/require_not_found'
    autoload :UpdateErrors,    'lunargraph/diagnostics/update_errors'
    autoload :TypeCheck,       'lunargraph/diagnostics/type_check'

    class << self
      # Add a reporter with a name to identify it in .lunargraph.yml files.
      #
      # @param name [String] The name
      # @param klass [Class<Lunargraph::Diagnostics::Base>] The class implementation
      # @return [void]
      def register name, klass
        reporter_hash[name] = klass
      end

      # Get an array of reporter names.
      #
      # @return [Array<String>]
      def reporters
        reporter_hash.keys - ['type_not_defined'] # @todo Hide type_not_defined for now
      end

      # Find a reporter by name.
      #
      # @param name [String] The name with which the reporter was registered
      # @return [Class<Lunargraph::Diagnostics::Base>]
      def reporter name
        reporter_hash[name]
      end

      private

      # @return [Hash]
      def reporter_hash
        @reporter_hash ||= {}
      end
    end

    register 'rubocop', Rubocop
    register 'require_not_found', RequireNotFound
    register 'typecheck', TypeCheck
    register 'update_errors', UpdateErrors
    register 'type_not_defined', TypeCheck # @todo Retained for backwards compatibility
  end
end
