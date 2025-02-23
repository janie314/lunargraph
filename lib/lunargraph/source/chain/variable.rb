# frozen_string_literal: true

module Lunargraph
  class Source
    class Chain
      class Variable < Link
        def resolve api_map, name_pin, _locals
          api_map.get_instance_variable_pins(name_pin.context.namespace, name_pin.context.scope).select do |p|
            p.name == word
          end
        end
      end
    end
  end
end
