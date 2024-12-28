# frozen_string_literal: true

module Lunargraph
  module Diagnostics
    # The base class for diagnostics reporters.
    #
    class Base
      # @return [Array<String>]
      attr_reader :args

      def initialize *args
        @args = args
      end

      # Perform a diagnosis on a Source within the context of an ApiMap.
      # The result is an array of hash objects that conform to the LSP's
      # Diagnostic specification.
      #
      # Subclasses should override this method.
      #
      # @param source [Lunargraph::Source]
      # @param api_map [Lunargraph::ApiMap]
      # @return [Array<Hash>]
      def diagnose _source, _api_map
        []
      end
    end
  end
end
