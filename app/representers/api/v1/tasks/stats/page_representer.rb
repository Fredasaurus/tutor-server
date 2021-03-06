module Api::V1
  module Tasks
    module Stats
      class PageRepresenter < Roar::Decorator

        include Roar::JSON
        include Representable::Coercion

        property :id,
                 type: String,
                 readable: true,
                 writeable: false

        property :title,
                 type: String,
                 readable: true,
                 writeable: false

        property :student_count,
                 type: Integer,
                 writeable: false,
                 readable: true

        property :correct_count,
                 type: Integer,
                 writeable: false,
                 readable: true

        property :incorrect_count,
                 type: Integer,
                 writeable: false,
                 readable: true

        property :chapter_section,
                 type: Array,
                 writeable: false,
                 readable: true,
                 schema_info: {
                   required: true,
                   description: 'The chapter and section in the book, e.g. [5, 2]'
                 }

        collection :exercises,
                   type: Object,
                   writeable: false,
                   readable: true,
                   decorator: Api::V1::Tasks::Stats::ExerciseRepresenter

        property :previous_attempt,
                 type: Object,
                 writeable: false,
                 readable: true,
                 decorator: self

      end
    end
  end
end
