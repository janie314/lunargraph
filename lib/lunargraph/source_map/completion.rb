# frozen_string_literal: true

module Lunargraph
  class SourceMap
    # The result of a completion request containing the pins that describe
    # completion options and the range to be replaced.
    #
    class Completion
      # @return [Array<Lunargraph::Pin::Base>]
      attr_reader :pins

      # @return [Lunargraph::Range]
      attr_reader :range

      # @param pins [Array<Lunargraph::Pin::Base>]
      # @param range [Lunargraph::Range]
      def initialize pins, range
        @pins = pins
        @range = range
      end
    end
  end
end
