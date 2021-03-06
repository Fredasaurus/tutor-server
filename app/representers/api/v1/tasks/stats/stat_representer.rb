module Api::V1
  module Tasks
    module Stats
      # Represents stats for course periods
      class StatRepresenter < Roar::Decorator

        include Roar::JSON
        include Representable::Coercion

        property :period_id,
                 type: String,
                 readable: true,
                 writeable: false

        property :name,
                 type: String,
                 readable: true,
                 writeable: false

        property :mean_grade_percent,
                 type: Integer,
                 readable: true,
                 writeable: false,
                 schema_info: {
                   minimum: 0,
                   maximum: 100
                 }

        property :total_count,
                 type: Integer,
                 readable: true,
                 writeable: false

        property :complete_count,
                 type: Integer,
                 readable: true,
                 writeable: false

        property :partially_complete_count,
                 type: Integer,
                 readable: true,
                 writeable: false

        collection :current_pages,
                   readable: true,
                   writable: false,
                   decorator: Api::V1::Tasks::Stats::PageRepresenter

        collection :spaced_pages,
                   readable: true,
                   writable: false,
                   decorator: Api::V1::Tasks::Stats::PageRepresenter

      end
    end
  end
end
