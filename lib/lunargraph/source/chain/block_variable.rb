# frozen_string_literal: true

module Lunargraph
  class Source
    class Chain
      class BlockVariable < Link
        def resolve _api_map, _name_pin, _locals
          [Pin::ProxyType.anonymous(ComplexType.try_parse('Proc'))]
        end
      end
    end
  end
end
