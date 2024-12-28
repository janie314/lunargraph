# frozen_string_literal: true

module Lunargraph
  class Source
    class Chain
      class Hash < Literal
        # @param type [String]
        # @param splatted [Boolean]
        def initialize type, splatted = false
          super(type)
          @splatted = splatted
        end

        def word
          @word ||= "<#{@type}>"
        end

        def resolve _api_map, _name_pin, _locals
          [Pin::ProxyType.anonymous(@complex_type)]
        end

        def splatted?
          @splatted
        end
      end
    end
  end
end
