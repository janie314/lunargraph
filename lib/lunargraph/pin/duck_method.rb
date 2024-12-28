# frozen_string_literal: true

module Lunargraph
  module Pin
    # DuckMethod pins are used to add completion items for type tags that
    # use duck typing, e.g., `@param file [#read]`.
    #
    class DuckMethod < Pin::Method
      # @param location [Lunargraph::Location]
      # @param name [String]
      # def initialize location, name
      #   # super(location, '', name, nil, :instance, :public, [])
      # end
    end
  end
end
