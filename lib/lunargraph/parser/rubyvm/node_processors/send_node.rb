# frozen_string_literal: true

module Lunargraph
  module Parser
    module Rubyvm
      module NodeProcessors
        class SendNode < Parser::NodeProcessor::Base
          include Rubyvm::NodeMethods

          def process
            if %i[private public protected].include?(node.children[0])
              process_visibility
            elsif node.children[0] == :module_function
              process_module_function
            elsif node.children[0] == :require
              process_require
            elsif node.children[0] == :autoload
              process_autoload
            elsif node.children[0] == :alias_method
              process_alias_method
            elsif node.children[0] == :private_class_method
              process_private_class_method
            elsif %i[attr_reader attr_writer attr_accessor].include?(node.children[0])
              process_attribute
            elsif node.children[0] == :include
              process_include
            elsif node.children[0] == :extend
              process_extend
            elsif node.children[0] == :prepend
              process_prepend
            elsif node.children[0] == :private_constant
              process_private_constant
            elsif node.children[1] == :require && unpack_name(node.children[0]) == 'Bundler'
              pins.push Pin::Reference::Require.new(
                Lunargraph::Location.new(region.filename, Lunargraph::Range.from_to(0, 0, 0, 0)), 'bundler/require'
              )
            end
            process_children
          end

          private

          # @return [void]
          def process_visibility
            if node.type == :FCALL && Parser.is_ast_node?(node.children.last)
              node.children.last.children[0..-2].each do |child|
                # next unless child.is_a?(AST::Node) && (child.type == :sym || child.type == :str)
                if child.type == :LIT || child.type == :STR
                  name = child.children[0].to_s
                  matches = pins.select do |pin|
                    pin.is_a?(Pin::Method) && pin.name == name && pin.namespace == region.closure.full_context.namespace && pin.context.scope == (region.scope || :instance)
                  end
                  matches.each do |pin|
                    # @todo Smelly instance variable access
                    pin.instance_variable_set(:@visibility, node.children[0])
                  end
                else
                  process_children region.update(visibility: node.children[0])
                end
              end
            else
              # @todo Smelly instance variable access
              region.instance_variable_set(:@visibility, node.children[0])
            end
          end

          # @return [void]
          def process_attribute
            return unless Parser.is_ast_node?(node.children[1])
            node.children[1].children[0..-2].each do |a|
              next unless a.type == :LIT
              loc = get_node_location(node)
              clos = region.closure
              cmnt = comments_for(node)
              if node.children[0] == :attr_reader || node.children[0] == :attr_accessor
                pins.push Lunargraph::Pin::Method.new(
                  location: loc,
                  closure: clos,
                  name: a.children[0].to_s,
                  comments: cmnt,
                  scope: region.scope || :instance,
                  visibility: region.visibility,
                  attribute: true
                )
              end
              next unless node.children[0] == :attr_writer || node.children[0] == :attr_accessor
              pins.push Lunargraph::Pin::Method.new(
                location: loc,
                closure: clos,
                name: "#{a.children[0]}=",
                comments: cmnt,
                scope: region.scope || :instance,
                visibility: region.visibility,
                attribute: true
              )
              pins.last.parameters.push Pin::Parameter.new(name: 'value', decl: :arg, closure: pins.last)
              if pins.last.return_type.defined?
                pins.last.docstring.add_tag YARD::Tags::Tag.new(:param, '', pins.last.return_type.to_s.split(', '),
                                                                'value')
              end
            end
          end

          # @return [void]
          def process_include
            return unless Parser.is_ast_node?(node.children.last)
            node.children.last.children[0..-2].each do |i|
              next unless %i[COLON2 COLON3 CONST].include?(i.type)
              type = region.scope == :class ? Pin::Reference::Extend : Pin::Reference::Include
              pins.push type.new(
                location: get_node_location(i),
                closure: region.closure,
                name: unpack_name(i)
              )
            end
          end

          # @return [void]
          def process_prepend
            return unless Parser.is_ast_node?(node.children.last)
            node.children.last.children[0..-2].each do |i|
              next unless %i[COLON2 COLON3 CONST].include?(i.type)
              pins.push Pin::Reference::Prepend.new(
                location: get_node_location(i),
                closure: region.closure,
                name: unpack_name(i)
              )
            end
          end

          # @return [void]
          def process_extend
            return unless Parser.is_ast_node?(node.children.last)
            node.children.last.children[0..-2].each do |i|
              next unless %i[COLON2 COLON3 CONST SELF].include?(i.type)
              loc = get_node_location(node)
              if i.type == :SELF
                pins.push Pin::Reference::Extend.new(
                  location: loc,
                  closure: region.closure,
                  name: region.closure.full_context.namespace
                )
              else
                pins.push Pin::Reference::Extend.new(
                  location: loc,
                  closure: region.closure,
                  name: unpack_name(i)
                )
              end
            end
          end

          # @return [void]
          def process_require
            return unless Parser.is_ast_node?(node.children[1])
            node.children[1].children.each do |arg|
              next unless Parser.is_ast_node?(arg)
              pins.push Pin::Reference::Require.new(get_node_location(arg), arg.children[0]) if arg.type == :STR
            end
          end

          # @return [void]
          def process_autoload
            return unless Parser.is_ast_node?(node.children[1]) && Parser.is_ast_node?(node.children[1].children[1])
            arg = node.children[1].children[1]
            return unless arg.type == :STR
            pins.push Pin::Reference::Require.new(get_node_location(arg), arg.children[0])
          end

          # @return [void]
          def process_module_function
            if node.type == :VCALL
              # @todo Smelly instance variable access
              region.instance_variable_set(:@visibility, :module_function)
            elsif node.children.last.children[0].type == :DEFN
              NodeProcessor.process node.children.last.children[0], region.update(visibility: :module_function), pins,
                                    locals
            else
              node.children.last.children[0..-2].each do |x|
                next unless %i[LIT STR].include?(x.type)
                cn = x.children[0].to_s
                ref = pins.find do |p|
                  p.is_a?(Pin::Method) && p.namespace == region.closure.full_context.namespace && p.name == cn
                end
                next if ref.nil?
                pins.delete ref
                mm = Lunargraph::Pin::Method.new(
                  location: ref.location,
                  closure: ref.closure,
                  name: ref.name,
                  comments: ref.comments,
                  scope: :class,
                  visibility: :public,
                  parameters: ref.parameters,
                  node: ref.node
                )
                cm = Lunargraph::Pin::Method.new(
                  location: ref.location,
                  closure: ref.closure,
                  name: ref.name,
                  comments: ref.comments,
                  scope: :instance,
                  visibility: :private,
                  parameters: ref.parameters,
                  node: ref.node
                )
                pins.push mm, cm
                pins.select { |pin| pin.is_a?(Pin::InstanceVariable) && pin.closure.path == ref.path }.each do |ivar|
                  pins.delete ivar
                  pins.push Lunargraph::Pin::InstanceVariable.new(
                    location: ivar.location,
                    closure: cm,
                    name: ivar.name,
                    comments: ivar.comments,
                    assignment: ivar.assignment
                    # scope: :instance
                  )
                  pins.push Lunargraph::Pin::InstanceVariable.new(
                    location: ivar.location,
                    closure: mm,
                    name: ivar.name,
                    comments: ivar.comments,
                    assignment: ivar.assignment
                    # scope: :class
                  )
                end
              end
            end
          end

          # @return [void]
          def process_private_constant
            arr = node.children[1]
            return unless Parser.is_ast_node?(arr) && %i[ARRAY LIST].include?(arr.type)

            arr.children.compact.each do |child|
              next unless %i[LIT STR].include?(child.type)
              cn = child.children[0].to_s
              ref = pins.find do |p|
                [Lunargraph::Pin::Namespace,
                 Lunargraph::Pin::Constant].include?(p.class) && p.namespace == region.closure.full_context.namespace && p.name == cn
              end
              # HACK: Smelly instance variable access
              ref&.instance_variable_set(:@visibility, :private)
            end
          end

          # @return [void]
          def process_alias_method
            arr = node.children[1]
            return if arr.nil?
            first = arr.children[0]
            second = arr.children[1]
            return unless first && second && %i[LIT STR].include?(first.type) && %i[LIT STR].include?(second.type)
            get_node_location(node)
            pins.push Lunargraph::Pin::MethodAlias.new(
              location: get_node_location(node),
              closure: region.closure,
              name: first.children[0].to_s,
              original: second.children[0].to_s,
              scope: region.scope || :instance
            )
          end

          # @return [void]
          def process_private_class_method
            return false unless Parser.is_ast_node?(node.children.last)
            if node.children.last.children.first.type == :DEFN
              process_children region.update(scope: :class, visibility: :private)
            else
              node.children.last.children[0..-2].each do |child|
                next unless child.type == :LIT && child.children.first.is_a?(::Symbol)
                sym_name = child.children.first.to_s
                ref = pins.find do |p|
                  p.is_a?(Pin::Method) && p.namespace == region.closure.full_context.namespace && p.name == sym_name
                end
                # HACK: Smelly instance variable access
                ref&.instance_variable_set(:@visibility, :private)
              end
            end
          end
        end
      end
    end
  end
end
