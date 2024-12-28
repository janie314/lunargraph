# frozen_string_literal: true

module Lunargraph
  module Pin
    class Reference < Base
      autoload :Require,    'lunargraph/pin/reference/require'
      autoload :Superclass, 'lunargraph/pin/reference/superclass'
      autoload :Include,    'lunargraph/pin/reference/include'
      autoload :Prepend,    'lunargraph/pin/reference/prepend'
      autoload :Extend,     'lunargraph/pin/reference/extend'
      autoload :Override,   'lunargraph/pin/reference/override'
    end
  end
end
