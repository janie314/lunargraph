# frozen_string_literal: true

module Lunargraph
  module LanguageServer
    class Request
      # @param id [Integer]
      # @param &block The block that processes the client's response
      def initialize id, &block
        @id = id
        @block = block
      end

      # @param result [Object]
      # @return [void]
      def process result
        @block&.call(result)
      end

      def send_response
        # noop
      end
    end
  end
end
