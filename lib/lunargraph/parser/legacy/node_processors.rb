# frozen_string_literal: true

require 'lunargraph/parser/node_processor'

module Lunargraph
  module Parser
    module Legacy
      module NodeProcessors
        autoload :BeginNode,     'lunargraph/parser/legacy/node_processors/begin_node'
        autoload :DefNode,       'lunargraph/parser/legacy/node_processors/def_node'
        autoload :DefsNode,      'lunargraph/parser/legacy/node_processors/defs_node'
        autoload :SendNode,      'lunargraph/parser/legacy/node_processors/send_node'
        autoload :NamespaceNode, 'lunargraph/parser/legacy/node_processors/namespace_node'
        autoload :SclassNode,    'lunargraph/parser/legacy/node_processors/sclass_node'
        autoload :ModuleNode,    'lunargraph/parser/legacy/node_processors/module_node'
        autoload :IvasgnNode,    'lunargraph/parser/legacy/node_processors/ivasgn_node'
        autoload :CvasgnNode,    'lunargraph/parser/legacy/node_processors/cvasgn_node'
        autoload :LvasgnNode,    'lunargraph/parser/legacy/node_processors/lvasgn_node'
        autoload :GvasgnNode,    'lunargraph/parser/legacy/node_processors/gvasgn_node'
        autoload :CasgnNode,     'lunargraph/parser/legacy/node_processors/casgn_node'
        autoload :AliasNode,     'lunargraph/parser/legacy/node_processors/alias_node'
        autoload :ArgsNode,      'lunargraph/parser/legacy/node_processors/args_node'
        autoload :BlockNode,     'lunargraph/parser/legacy/node_processors/block_node'
        autoload :OrasgnNode,    'lunargraph/parser/legacy/node_processors/orasgn_node'
        autoload :SymNode,       'lunargraph/parser/legacy/node_processors/sym_node'
        autoload :ResbodyNode,   'lunargraph/parser/legacy/node_processors/resbody_node'
      end
    end

    module NodeProcessor
      register :source,  Legacy::NodeProcessors::BeginNode
      register :begin,   Legacy::NodeProcessors::BeginNode
      register :kwbegin, Legacy::NodeProcessors::BeginNode
      register :rescue,  Legacy::NodeProcessors::BeginNode
      register :resbody, Legacy::NodeProcessors::ResbodyNode
      register :def,     Legacy::NodeProcessors::DefNode
      register :defs,    Legacy::NodeProcessors::DefsNode
      register :send,    Legacy::NodeProcessors::SendNode
      register :class,   Legacy::NodeProcessors::NamespaceNode
      register :module,  Legacy::NodeProcessors::NamespaceNode
      register :sclass,  Legacy::NodeProcessors::SclassNode
      register :ivasgn,  Legacy::NodeProcessors::IvasgnNode
      register :cvasgn,  Legacy::NodeProcessors::CvasgnNode
      register :lvasgn,  Legacy::NodeProcessors::LvasgnNode
      register :gvasgn,  Legacy::NodeProcessors::GvasgnNode
      register :casgn,   Legacy::NodeProcessors::CasgnNode
      register :alias,   Legacy::NodeProcessors::AliasNode
      register :args,    Legacy::NodeProcessors::ArgsNode
      register :block,   Legacy::NodeProcessors::BlockNode
      register :or_asgn, Legacy::NodeProcessors::OrasgnNode
      register :sym,     Legacy::NodeProcessors::SymNode
    end
  end
end
