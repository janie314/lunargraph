# frozen_string_literal: true

module Lunargraph
  module Parser
    class Snippet
      attr_reader :range, :text

      def initialize range, text
        @range = range
        @text = text
      end
    end
  end
end
