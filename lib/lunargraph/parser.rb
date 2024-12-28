# frozen_string_literal: true

module Lunargraph
  module Parser
    autoload :CommentRipper, 'lunargraph/parser/comment_ripper'
    autoload :Legacy, 'lunargraph/parser/legacy'
    autoload :Rubyvm, 'lunargraph/parser/rubyvm'
    autoload :Region, 'lunargraph/parser/region'
    autoload :NodeProcessor, 'lunargraph/parser/node_processor'
    autoload :Snippet, 'lunargraph/parser/snippet'

    class SyntaxError < StandardError
    end

    # True if the parser can use RubyVM.
    #
    def self.rubyvm?
      !!defined?(RubyVM::AbstractSyntaxTree)
      # false
    end

    selected = rubyvm? ? Rubyvm : Legacy
    # include selected
    extend selected::ClassMethods

    NodeMethods = (rubyvm? ? Rubyvm::NodeMethods : Legacy::NodeMethods)
  end
end
