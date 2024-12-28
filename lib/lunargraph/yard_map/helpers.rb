# frozen_string_literal: true

module Lunargraph
  class YardMap
    module Helpers
      module_function

      # @param code_object [YARD::CodeObjects::Base]
      # @param spec [Gem::Specification]
      # @return [Lunargraph::Location, nil]
      def object_location code_object, spec
        return nil if spec.nil? || code_object.nil? || code_object.file.nil? || code_object.line.nil?
        file = File.join(spec.full_gem_path, code_object.file)
        Lunargraph::Location.new(file, Lunargraph::Range.from_to(code_object.line - 1, 0, code_object.line - 1, 0))
      end
    end
  end
end
