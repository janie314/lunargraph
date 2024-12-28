# frozen_string_literal: true

module Lunargraph
  module Pin
    class ProxyType < Base
      # @param return_type [ComplexType]
      def initialize return_type: ComplexType::UNDEFINED, **splat
        super(**splat)
        @return_type = return_type
      end

      def context
        @return_type
      end

      # @param return_type [ComplexType]
      # @return [ProxyType]
      def self.anonymous return_type
        parts = return_type.namespace.split('::')
        namespace = parts[0..-2].join('::').to_s
        parts.last.to_s
        # ProxyType.new(nil, namespace, name, return_type)
        ProxyType.new(
          closure: Lunargraph::Pin::Namespace.new(name: namespace), return_type: return_type
        )
      end
    end
  end
end
