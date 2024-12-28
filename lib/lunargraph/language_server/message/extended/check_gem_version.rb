# frozen_string_literal: true

require 'rubygems'

module Lunargraph
  module LanguageServer
    module Message
      module Extended
        # Check if a more recent version of the Lunargraph gem is available.
        # Notify the client when an update exists. If the `verbose` parameter
        # is true, notify the client when the gem is up to date.
        #
        class CheckGemVersion < Base
          def self.fetcher
            @fetcher ||= Gem::SpecFetcher.new
          end

          class << self
            attr_writer :fetcher
          end

          GEM_ZERO = Gem::Version.new('0.0.0')

          def initialize host, request, current: Gem::Version.new(Lunargraph::VERSION), available: nil
            super(host, request)
            @current = current
            @available = available
          end

          def process
            if available > GEM_ZERO
              if available > current
                host.show_message_request "Lunargraph gem version #{available} is available. (Current version: #{current})",
                                          LanguageServer::MessageTypes::INFO,
                                          ['Update now'] do |result|
                                            next unless result == 'Update now'
                                            cmd = if host.options['useBundler']
                                                    'bundle update lunargraph'
                                                  else
                                                    'gem update lunargraph'
                                                  end
                                            _, s = Open3.capture2(cmd)
                                            if s.zero?
                                              host.show_message 'Successfully updated the Lunargraph gem.',
                                                                LanguageServer::MessageTypes::INFO
                                              host.send_notification '$/lunargraph/restart', {}
                                            else
                                              host.show_message 'An error occurred while updating the gem.',
                                                                LanguageServer::MessageTypes::ERROR
                                            end
                                          end
              elsif params['verbose']
                host.show_message "The Lunargraph gem is up to date (version #{Lunargraph::VERSION})."
              end
            elsif fetched?
              Lunargraph::Logging.logger.warn error
              host.show_message(error, MessageTypes::ERROR) if params['verbose']
            end
            set_result({
                         installed: current,
                         available: available
                       })
          end

          private

          # @return [Gem::Version]
          attr_reader :current

          # @return [Gem::Version]
          def available
            if !@available && !@fetched
              @fetched = true
              begin
                @available ||= begin
                  tuple = CheckGemVersion.fetcher.search_for_dependency(Gem::Dependency.new('lunargraph')).flatten.first
                  if tuple.nil?
                    @error = 'An error occurred fetching the gem data'
                    GEM_ZERO
                  else
                    tuple.version
                  end
                end
              rescue Errno::EADDRNOTAVAIL => e
                @error = "Unable to connect to gem source: #{e.message}"
                GEM_ZERO
              end
            end
            @available
          end

          def fetched?
            @fetched ||= false
          end

          # @return [String, nil]
          attr_reader :error
        end
      end
    end
  end
end
