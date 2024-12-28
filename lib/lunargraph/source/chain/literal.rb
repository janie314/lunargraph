# frozen_string_literal: true

module Lunargraph
  class Source
    class Chain
      class Literal < Link
        def word
          @word ||= "<#{@type}>"
        end

        # @param type [String]
        def initialize type
          @type = type
          @complex_type = ComplexType.try_parse(type)
        end

        def resolve _api_map, _name_pin, _locals
          [Pin::ProxyType.anonymous(@complex_type)]
        end
      end
    end
  end
end
