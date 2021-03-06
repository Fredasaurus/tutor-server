module Api::V1
  class PracticeRepresenter < Roar::Decorator

    include Roar::JSON

    collection :page_ids,
               writeable: true,
               readable: false,
               schema_info: {
                 description: "The page_ids to use for practice",
                 items: {
                   type: 'string'
                 }
               }

    collection :book_part_ids,
               writeable: true,
               readable: false,
               schema_info: {
                 description: "The book_part_ids to use for practice",
                 items: {
                   type: 'string'
                 }
               }

  end
end
