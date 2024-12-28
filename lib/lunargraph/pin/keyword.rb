# frozen_string_literal: true

module Lunargraph
  module Pin
    class Keyword < Base
      def initialize name
        super(name: name)
      end

      attr_reader :name
    end
  end
end
