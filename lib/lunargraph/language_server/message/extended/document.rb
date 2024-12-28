# frozen_string_literal: true

module Lunargraph
  module LanguageServer
    module Message
      module Extended
        class Document < Base
          def process
            objects = host.document(params['query'])
            page = Lunargraph::Page.new(host.options['viewsPath'])
            content = page.render('document', layout: true, locals: { objects: objects })
            set_result(
              content: content
            )
          end
        end
      end
    end
  end
end
