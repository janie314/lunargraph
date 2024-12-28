# frozen_string_literal: true

module Lunargraph
  class Source
    class Chain
      class Or < Link
        def word
          '<or>'
        end

        # @param type [String]
        def initialize links
          @links = links
        end

        def resolve api_map, name_pin, locals
          types = @links.map { |link| link.infer(api_map, name_pin, locals) }
          [Lunargraph::Pin::ProxyType.anonymous(Lunargraph::ComplexType.try_parse(types.map(&:tag).uniq.join(', ')))]
        end
      end
    end
  end
end
