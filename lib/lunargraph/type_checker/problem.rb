# frozen_string_literal: true

module Lunargraph
  class TypeChecker
    # A problem reported by TypeChecker.
    #
    class Problem
      # @return [Lunargraph::Location]
      attr_reader :location

      # @return [String]
      attr_reader :message

      # @return [Pin::Base]
      attr_reader :pin

      # @return [String, nil]
      attr_reader :suggestion

      # @param location [Lunargraph::Location]
      # @param message [String]
      # @param pin [Lunargraph::Pin::Base, nil]
      # @param suggestion [String, nil]
      def initialize location, message, pin: nil, suggestion: nil
        @location = location
        @message = message
        @pin = pin
        @suggestion = suggestion
      end
    end
  end
end
