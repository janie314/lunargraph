# frozen_string_literal: true

module Lunargraph
  class Source
    class Chain
      class ClassVariable < Link
        def resolve api_map, name_pin, _locals
          api_map.get_class_variable_pins(name_pin.context.namespace).select { |p| p.name == word }
        end
      end
    end
  end
end
