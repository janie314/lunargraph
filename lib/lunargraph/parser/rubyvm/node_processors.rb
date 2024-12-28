# frozen_string_literal: true

require 'lunargraph/parser/node_processor'

module Lunargraph
  module Parser
    module Rubyvm
      module NodeProcessors
        autoload :ScopeNode,     'lunargraph/parser/rubyvm/node_processors/scope_node'
        autoload :BeginNode,     'lunargraph/parser/rubyvm/node_processors/begin_node'
        autoload :DefNode,       'lunargraph/parser/rubyvm/node_processors/def_node'
        autoload :DefsNode,      'lunargraph/parser/rubyvm/node_processors/defs_node'
        autoload :SendNode,      'lunargraph/parser/rubyvm/node_processors/send_node'
        autoload :NamespaceNode, 'lunargraph/parser/rubyvm/node_processors/namespace_node'
        autoload :SclassNode,    'lunargraph/parser/rubyvm/node_processors/sclass_node'
        autoload :ModuleNode,    'lunargraph/parser/rubyvm/node_processors/module_node'
        autoload :IvasgnNode,    'lunargraph/parser/rubyvm/node_processors/ivasgn_node'
        autoload :CvasgnNode,    'lunargraph/parser/rubyvm/node_processors/cvasgn_node'
        autoload :LvasgnNode,    'lunargraph/parser/rubyvm/node_processors/lvasgn_node'
        autoload :GvasgnNode,    'lunargraph/parser/rubyvm/node_processors/gvasgn_node'
        autoload :CasgnNode,     'lunargraph/parser/rubyvm/node_processors/casgn_node'
        autoload :AliasNode,     'lunargraph/parser/rubyvm/node_processors/alias_node'
        autoload :ArgsNode,      'lunargraph/parser/rubyvm/node_processors/args_node'
        autoload :OptArgNode,    'lunargraph/parser/rubyvm/node_processors/opt_arg_node'
        autoload :KwArgNode,     'lunargraph/parser/rubyvm/node_processors/kw_arg_node'
        autoload :BlockNode,     'lunargraph/parser/rubyvm/node_processors/block_node'
        autoload :OrasgnNode,    'lunargraph/parser/rubyvm/node_processors/orasgn_node'
        autoload :SymNode,       'lunargraph/parser/rubyvm/node_processors/sym_node'
        autoload :LitNode,       'lunargraph/parser/rubyvm/node_processors/lit_node'
        autoload :ResbodyNode,   'lunargraph/parser/rubyvm/node_processors/resbody_node'
      end
    end

    module NodeProcessor
      register :SCOPE,      Rubyvm::NodeProcessors::ScopeNode
      register :RESBODY,    Rubyvm::NodeProcessors::ResbodyNode
      register :DEFN,       Rubyvm::NodeProcessors::DefNode
      register :DEFS,       Rubyvm::NodeProcessors::DefsNode
      register :CALL,       Rubyvm::NodeProcessors::SendNode
      register :FCALL,      Rubyvm::NodeProcessors::SendNode
      register :VCALL,      Rubyvm::NodeProcessors::SendNode
      register :CLASS,      Rubyvm::NodeProcessors::NamespaceNode
      register :MODULE,     Rubyvm::NodeProcessors::NamespaceNode
      register :SCLASS,     Rubyvm::NodeProcessors::SclassNode
      register :IASGN,      Rubyvm::NodeProcessors::IvasgnNode
      register :CVASGN,     Rubyvm::NodeProcessors::CvasgnNode
      register :LASGN,      Rubyvm::NodeProcessors::LvasgnNode
      register :DASGN,      Rubyvm::NodeProcessors::LvasgnNode
      register :DASGN_CURR, Rubyvm::NodeProcessors::LvasgnNode
      register :GASGN,      Rubyvm::NodeProcessors::GvasgnNode
      register :CDECL,      Rubyvm::NodeProcessors::CasgnNode
      register :ALIAS,      Rubyvm::NodeProcessors::AliasNode
      register :ARGS,       Rubyvm::NodeProcessors::ArgsNode
      register :OPT_ARG,    Rubyvm::NodeProcessors::OptArgNode
      register :KW_ARG,     Rubyvm::NodeProcessors::KwArgNode
      register :ITER,       Rubyvm::NodeProcessors::BlockNode
      register :LAMBDA,     Rubyvm::NodeProcessors::BlockNode
      register :FOR,        Rubyvm::NodeProcessors::BlockNode
      register :OP_ASGN_OR, Rubyvm::NodeProcessors::OrasgnNode
      register :LIT,        Rubyvm::NodeProcessors::LitNode
    end
  end
end
