# frozen_string_literal: true

module Lunargraph
  module Pin
    class Reference
      class Require < Reference
        def initialize location, name
          # super(location, '', name)
          super(location: location, name: name)
        end
      end
    end
  end
end
