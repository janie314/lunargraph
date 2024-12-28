# frozen_string_literal: true

module Lunargraph
  module Parser
    module Legacy
      autoload :FlawedBuilder, 'lunargraph/parser/legacy/flawed_builder'
      autoload :ClassMethods, 'lunargraph/parser/legacy/class_methods'
      autoload :NodeMethods, 'lunargraph/parser/legacy/node_methods'
      autoload :NodeChainer, 'lunargraph/parser/legacy/node_chainer'
    end
  end
end

require 'lunargraph/parser/legacy/node_processors'
