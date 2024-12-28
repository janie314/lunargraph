# frozen_string_literal: true

module Lunargraph
  module Pin
    class Constant < BaseVariable
      attr_reader :visibility

      def initialize visibility: :public, **splat
        super(**splat)
        @visibility = visibility
      end

      def return_type
        @return_type ||= generate_complex_type
      end

      def completion_item_kind
        Lunargraph::LanguageServer::CompletionItemKinds::CONSTANT
      end

      # @return [Integer]
      def symbol_kind
        LanguageServer::SymbolKinds::CONSTANT
      end

      def path
        @path ||= context.namespace.to_s.empty? ? name : "#{context.namespace}::#{name}"
      end

      private

      # @return [ComplexType]
      def generate_complex_type
        tags = docstring.tags(:return).map(&:types).flatten.compact
        tags = docstring.tags(:type).map(&:types).flatten.compact if tags.empty?
        return ComplexType::UNDEFINED if tags.empty?
        ComplexType.try_parse(*tags)
      end
    end
  end
end
