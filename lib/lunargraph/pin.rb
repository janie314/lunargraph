# frozen_string_literal: true

require 'yard'

module Lunargraph
  # The namespace for pins used in maps.
  #
  module Pin
    autoload :Common,           'lunargraph/pin/common'
    autoload :Conversions,      'lunargraph/pin/conversions'
    autoload :Base,             'lunargraph/pin/base'
    autoload :Method,           'lunargraph/pin/method'
    autoload :Signature,        'lunargraph/pin/signature'
    autoload :MethodAlias,      'lunargraph/pin/method_alias'
    autoload :BaseVariable,     'lunargraph/pin/base_variable'
    autoload :InstanceVariable, 'lunargraph/pin/instance_variable'
    autoload :ClassVariable,    'lunargraph/pin/class_variable'
    autoload :LocalVariable,    'lunargraph/pin/local_variable'
    autoload :GlobalVariable,   'lunargraph/pin/global_variable'
    autoload :Constant,         'lunargraph/pin/constant'
    autoload :Symbol,           'lunargraph/pin/symbol'
    autoload :Closure,          'lunargraph/pin/closure'
    autoload :Namespace,        'lunargraph/pin/namespace'
    autoload :Keyword,          'lunargraph/pin/keyword'
    autoload :Parameter,        'lunargraph/pin/parameter'
    autoload :Reference,        'lunargraph/pin/reference'
    autoload :Documenting,      'lunargraph/pin/documenting'
    autoload :Block,            'lunargraph/pin/block'
    autoload :Localized,        'lunargraph/pin/localized'
    autoload :ProxyType,        'lunargraph/pin/proxy_type'
    autoload :DuckMethod,       'lunargraph/pin/duck_method'
    autoload :Singleton,        'lunargraph/pin/singleton'
    autoload :KeywordParam,     'lunargraph/pin/keyword_param'
    autoload :Search,           'lunargraph/pin/search'

    ROOT_PIN = Pin::Namespace.new(type: :class, name: '', closure: nil)
  end
end
