# frozen_string_literal: true

module Lunargraph
  module LanguageServer
    # The Transport namespace contains concrete implementations of
    # communication protocols for language servers.
    #
    module Transport
      autoload :Adapter,    'lunargraph/language_server/transport/adapter'
      autoload :DataReader, 'lunargraph/language_server/transport/data_reader'
    end
  end
end
