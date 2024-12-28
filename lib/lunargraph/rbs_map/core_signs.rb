# frozen_string_literal: true

module Lunargraph
  class RbsMap
    module CoreSigns
      Override = Pin::Reference::Override

      class Stub
        attr_reader :parameters, :return_type

        def initialize parameters, return_type
          @parameters = parameters
          @return_type = return_type
        end
      end

      SIGNATURE_MAP = {
        'Object#class' => [
          Stub.new(
            [],
            'Class<self>'
          )
        ]
      }.freeze

      # @param path [String]
      # @return [Array<Stub>]
      def self.sign path
        SIGNATURE_MAP[path]
      end
    end
  end
end
