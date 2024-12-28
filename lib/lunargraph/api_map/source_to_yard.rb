# frozen_string_literal: true

module Lunargraph
  class ApiMap
    module SourceToYard
      # Get the YARD CodeObject at the specified path.
      #
      # @param path [String]
      # @return [YARD::CodeObjects::Base]
      def code_object_at path
        code_object_map[path]
      end

      # @return [Array<String>]
      def code_object_paths
        code_object_map.keys
      end

      # @param store [ApiMap::Store] ApiMap pin store
      # @return [void]
      def rake_yard store
        YARD::Registry.clear
        code_object_map.clear
        store.namespace_pins.each do |pin|
          next if pin.path.nil? || pin.path.empty?
          if pin.code_object
            code_object_map[pin.path] ||= pin.code_object
            next
          end
          if pin.type == :class
            code_object_map[pin.path] ||= YARD::CodeObjects::ClassObject.new(root_code_object, pin.path) do |obj|
              next if pin.location.nil? || pin.location.filename.nil?
              obj.add_file(pin.location.filename, pin.location.range.start.line, !pin.comments.empty?)
            end
          else
            code_object_map[pin.path] ||= YARD::CodeObjects::ModuleObject.new(root_code_object, pin.path) do |obj|
              next if pin.location.nil? || pin.location.filename.nil?
              obj.add_file(pin.location.filename, pin.location.range.start.line, !pin.comments.empty?)
            end
          end
          code_object_map[pin.path].docstring = pin.docstring
          store.get_includes(pin.path).each do |ref|
            unless code_object_map[ref].nil? || code_object_map[pin.path].nil?
              code_object_map[pin.path].instance_mixins.push code_object_map[ref]
            end
          end
          store.get_extends(pin.path).each do |ref|
            unless code_object_map[ref].nil? || code_object_map[pin.path].nil?
              code_object_map[pin.path].instance_mixins.push code_object_map[ref]
            end
            unless code_object_map[ref].nil? || code_object_map[pin.path].nil?
              code_object_map[pin.path].class_mixins.push code_object_map[ref]
            end
          end
        end
        store.method_pins.each do |pin|
          if pin.code_object
            code_object_map[pin.path] ||= pin.code_object
            next
          end
          code_object_map[pin.path] ||= YARD::CodeObjects::MethodObject.new(code_object_at(pin.namespace), pin.name,
                                                                            pin.scope) do |obj|
            next if pin.location.nil? || pin.location.filename.nil?
            obj.add_file pin.location.filename, pin.location.range.start.line
          end
          code_object_map[pin.path].docstring = pin.docstring
          code_object_map[pin.path].visibility = pin.visibility || :public
          code_object_map[pin.path].parameters = pin.parameters.map do |p|
            [p.name, p.asgn_code]
          end
        end
      end

      private

      # @return [Hash{String => YARD::CodeObjects::Base}]
      def code_object_map
        @code_object_map ||= {}
      end

      # @return [YARD::CodeObjects::RootObject]
      def root_code_object
        @root_code_object ||= YARD::CodeObjects::RootObject.new(nil, 'root')
      end
    end
  end
end
