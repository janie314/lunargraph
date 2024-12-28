# frozen_string_literal: true

require 'parser'

module Lunargraph
  module Parser
    module Legacy
      module NodeMethods
        module_function

        # @param node [Parser::AST::Node]
        # @return [String]
        def unpack_name(node)
          pack_name(node).join('::')
        end

        # @param node [Parser::AST::Node]
        # @return [Array<String>]
        def pack_name(node)
          parts = []
          if node.is_a?(AST::Node)
            node.children.each do |n|
              if n.is_a?(AST::Node)
                if n.type == :cbase
                  parts = [''] + pack_name(n)
                else
                  parts += pack_name(n)
                end
              else
                parts.push n unless n.nil?
              end
            end
          end
          parts
        end

        # @param node [Parser::AST::Node]
        # @return [String, nil]
        def infer_literal_node_type node
          return nil unless node.is_a?(AST::Node)
          case node.type
          when :str, :dstr
            return '::String'
          when :array
            return '::Array'
          when :hash
            return '::Hash'
          when :int
            return '::Integer'
          when :float
            return '::Float'
          when :sym
            return '::Symbol'
          when :regexp
            return '::Regexp'
          when :irange
            return '::Range'
          when true, false
            return '::Boolean'
            # @todo Support `nil` keyword in types
            # elsif node.type == :nil
            #   return 'NilClass'
          end
          nil
        end

        # @param node [Parser::AST::Node]
        # @return [Position]
        def get_node_start_position(node)
          Position.new(node.loc.line, node.loc.column)
        end

        # @param node [Parser::AST::Node]
        # @return [Position]
        def get_node_end_position(node)
          Position.new(node.loc.last_line, node.loc.last_column)
        end

        def drill_signature node, signature
          return signature unless node.is_a?(AST::Node)
          case node.type
          when :const, :cbase
            signature += drill_signature(node.children[0], signature) unless node.children[0].nil?
            signature += '::' unless signature.empty?
            signature += node.children[1].to_s
          when :lvar, :ivar, :cvar
            signature += '.' unless signature.empty?
            signature += node.children[0].to_s
          when :send
            signature += drill_signature(node.children[0], signature) unless node.children[0].nil?
            signature += '.' unless signature.empty?
            signature += node.children[1].to_s
          end
          signature
        end

        def convert_hash node
          return {} unless Parser.is_ast_node?(node)
          return convert_hash(node.children[0]) if node.type == :kwsplat
          if Parser.is_ast_node?(node.children[0]) && node.children[0].type == :kwsplat
            return convert_hash(node.children[0])
          end
          return {} unless node.type == :hash
          result = {}
          node.children.each do |pair|
            result[pair.children[0].children[0]] = Lunargraph::Parser.chain(pair.children[1])
          end
          result
        end

        NIL_NODE = ::Parser::AST::Node.new(:nil)

        def const_nodes_from node
          return [] unless Parser.is_ast_node?(node)
          result = []
          if node.type == :const
            result.push node
          else
            node.children.each { |child| result.concat const_nodes_from(child) }
          end
          result
        end

        def splatted_hash? node
          Parser.is_ast_node?(node.children[0]) && node.children[0].type == :kwsplat
        end

        def splatted_call? node
          return false unless Parser.is_ast_node?(node)
          Parser.is_ast_node?(node.children[0]) && node.children[0].type == :kwsplat && node.children[0].children[0].type != :hash
        end

        def any_splatted_call?(nodes)
          nodes.any? { |n| splatted_call?(n) }
        end

        # @todo Temporarily here for testing. Move to Lunargraph::Parser.
        def call_nodes_from node
          return [] unless node.is_a?(::Parser::AST::Node)
          result = []
          if node.type == :block
            result.push node
            if Parser.is_ast_node?(node.children[0]) && node.children[0].children.length > 2
              node.children[0].children[2..].each { |child| result.concat call_nodes_from(child) }
            end
            node.children[1..].each { |child| result.concat call_nodes_from(child) }
          elsif node.type == :send
            result.push node
            node.children[2..].each { |child| result.concat call_nodes_from(child) }
          elsif %i[super zsuper].include?(node.type)
            result.push node
            node.children.each { |child| result.concat call_nodes_from(child) }
          elsif node.type == :masgn
            # @todo We're treating a mass assignment as a call node, but the
            #   type checker still needs the logic to handle it.
            result.push node
          else
            node.children.each { |child| result.concat call_nodes_from(child) }
          end
          result
        end

        # Find all the nodes within the provided node that potentially return a
        # value.
        #
        # The node parameter typically represents a method's logic, e.g., the
        # second child (after the :args node) of a :def node. A simple one-line
        # method would typically return itself, while a node with conditions
        # would return the resulting node from each conditional branch. Nodes
        # that follow a :return node are assumed to be unreachable. Nil values
        # are converted to nil node types.
        #
        # @param node [Parser::AST::Node]
        # @return [Array<Parser::AST::Node>]
        def returns_from node
          DeepInference.get_return_nodes(node).map { |n| n || NIL_NODE }
        end

        # @param cursor [Lunargraph::Source::Cursor]
        def find_recipient_node cursor
          if cursor.source.repaired? && cursor.source.code[cursor.offset - 1] == '('
            return repaired_find_recipient_node(cursor)
          end
          source = cursor.source
          position = cursor.position
          offset = cursor.offset
          tree = if source.synchronized?
                   match = source.code[0..offset - 1].match(/,\s*\z/)
                   if match
                     source.tree_at(position.line, position.column - match[0].length)
                   else
                     source.tree_at(position.line, position.column)
                   end
                 else
                   source.tree_at(position.line, position.column - 1)
                 end
          prev = nil
          tree.each do |node|
            if node.type == :send
              args = node.children[2..]
              if !args.empty?
                return node if prev && args.include?(prev)
              elsif source.synchronized?
                return node if source.code[0..offset - 1] =~ /\(\s*\z/ && source.code[offset..] =~ /^\s*\)/
              elsif /\([^\(]*\z/.match?(source.code[0..offset - 1])
                return node
              end
            end
            prev = node
          end
          nil
        end

        def repaired_find_recipient_node cursor
          cursor = cursor.source.cursor_at([cursor.position.line, cursor.position.column - 1])
          node = cursor.source.tree_at(cursor.position.line, cursor.position.column).first
          node if node && node.type == :send
        end

        module DeepInference
          class << self
            CONDITIONAL = %i[if unless].freeze
            REDUCEABLE = %i[begin kwbegin].freeze
            SKIPPABLE = %i[def defs class sclass module].freeze

            # @param node [Parser::AST::Node]
            # @return [Array<Parser::AST::Node>]
            def get_return_nodes node
              return [] unless node.is_a?(::Parser::AST::Node)
              result = []
              if REDUCEABLE.include?(node.type)
                result.concat get_return_nodes_from_children(node)
              elsif CONDITIONAL.include?(node.type)
                result.concat reduce_to_value_nodes(node.children[1..])
                # result.push NIL_NODE unless node.children[2]
              elsif node.type == :or
                result.concat reduce_to_value_nodes(node.children)
              elsif node.type == :return
                result.concat reduce_to_value_nodes([node.children[0]])
              elsif node.type == :block
                result.push node
                result.concat get_return_nodes_only(node.children[2])
              elsif node.type == :case
                node.children[1..].each do |cc|
                  if cc.nil?
                    result.push NIL_NODE
                  else
                    result.concat reduce_to_value_nodes(cc.children[1..-2]) unless cc.children.empty?
                    result.concat reduce_to_value_nodes([cc.children.last])
                  end
                end
              else
                result.push node
              end
              result
            end

            private

            def get_return_nodes_from_children parent
              result = []
              nodes = parent.children.select { |n| n.is_a?(AST::Node) }
              nodes.each_with_index do |node, idx|
                if node.type == :block
                  result.concat get_return_nodes_only(node.children[2])
                elsif SKIPPABLE.include?(node.type)
                  next
                elsif node.type == :return
                  result.concat reduce_to_value_nodes([node.children[0]])
                  # Return the result here because the rest of the code is
                  # unreachable
                  return result
                else
                  result.concat get_return_nodes_only(node)
                end
                result.concat reduce_to_value_nodes([nodes.last]) if idx == nodes.length - 1
              end
              result
            end

            def get_return_nodes_only parent
              return [] unless parent.is_a?(::Parser::AST::Node)
              result = []
              nodes = parent.children.select { |n| n.is_a?(::Parser::AST::Node) }
              nodes.each do |node|
                next if SKIPPABLE.include?(node.type)
                if node.type == :return
                  result.concat reduce_to_value_nodes([node.children[0]])
                  # Return the result here because the rest of the code is
                  # unreachable
                  return result
                else
                  result.concat get_return_nodes_only(node)
                end
              end
              result
            end

            def reduce_to_value_nodes nodes
              result = []
              nodes.each do |node|
                if !node.is_a?(::Parser::AST::Node)
                  result.push nil
                elsif REDUCEABLE.include?(node.type)
                  result.concat get_return_nodes_from_children(node)
                elsif CONDITIONAL.include?(node.type)
                  result.concat reduce_to_value_nodes(node.children[1..])
                elsif node.type == :return
                  result.concat reduce_to_value_nodes([node.children[0]])
                elsif node.type == :or
                  result.concat reduce_to_value_nodes(node.children)
                elsif node.type == :block
                  result.concat get_return_nodes_only(node.children[2])
                else
                  result.push node
                end
              end
              result
            end
          end
        end
      end
    end
  end
end
