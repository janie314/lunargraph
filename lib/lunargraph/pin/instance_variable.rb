# frozen_string_literal: true

module Lunargraph
  module Pin
    class InstanceVariable < BaseVariable
      def binder
        closure.binder
      end

      def scope
        closure.binder.scope
      end

      def context
        @context ||= begin
          result = super
          if scope == :class
            ComplexType.parse("Class<#{result.namespace}>")
          else
            ComplexType.parse(result.namespace.to_s)
          end
        end
      end

      def nearly? other
        super && binder == other.binder
      end
    end
  end
end
