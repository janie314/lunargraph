# frozen_string_literal: true

module Lunargraph
  module LanguageServer
    module Message
      module TextDocument
        class Completion < Base
          def process
            if host.has_pending_completions?
              return set_error(ErrorCodes::REQUEST_CANCELLED,
                               'cancelled by so many request')
            end

            line = params['position']['line']
            col = params['position']['character']
            begin
              completion = host.completions_at(params['textDocument']['uri'], line, col)
              return set_result(empty_result) if host.cancel?(id) && host.cancel?(id)
              items = []
              last_context = nil
              idx = -1
              completion.pins.each do |pin|
                idx += 1 if last_context != pin.context
                items.push pin.completion_item.merge({
                                                       textEdit: {
                                                         range: completion.range.to_hash,
                                                         newText: pin.name.sub(/=$/, ' = ').sub(/:$/, ': ')
                                                       },
                                                       sortText: "#{idx.to_s.rjust(4, '0')}#{pin.name}"
                                                     })
                items.last[:data][:uri] = params['textDocument']['uri']
                last_context = pin.context
              end
              set_result(
                isIncomplete: false,
                items: items
              )
            rescue InvalidOffsetError
              Logging.logger.info "Completion ignored invalid offset: #{params['textDocument']['uri']}, line #{line}, character #{col}"
              set_result empty_result
            end
          rescue FileNotFoundError => e
            Logging.logger.warn "[#{e.class}] #{e.message}"
            Logging.logger.warn e.backtrace.join("\n")
            set_result empty_result
          end

          # @param incomplete [Boolean]
          # @return [Hash]
          def empty_result incomplete = false
            {
              isIncomplete: incomplete,
              items: []
            }
          end
        end
      end
    end
  end
end
