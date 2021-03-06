module Api::V1
  class BookPartTocRepresenter < Roar::Decorator

    include Roar::JSON
    include Representable::Coercion

    property :id,
             type: String,
             writeable: false,
             readable: true,
             schema_info: { required: true }

    property :cnx_id,
             type: String,
             writeable: false,
             readable: true,
             schema_info: {
               required: false,
               description: 'The cnx id of the page, e.g. "95e61258-2faf-41d4-af92-f62e1414175a@3"'
             }

    property :title,
             type: String,
             writeable: false,
             readable: true,
             schema_info: { required: true }

    property :type,
             type: String,
             writeable: false,
             readable: true,
             schema_info: {
               required: true,
               description: 'The type of the TOC entry, either "part" (for units, chapters, etc), or "page"'
             }

    property :chapter_section,
             type: Array,
             writeable: false,
             readable: true,
             schema_info: {
               required: true,
               description: 'The chapter and section in the book, e.g. [5, 2]'
             }

    collection :children,
               as: :children,
               writeable: false,
               readable: true,
               decorator: BookPartTocRepresenter,
               schema_info: {
                 required: false,
                 description: "The parts of the book (units, chapters, pages, etc)"
               }
  end
end
