module Api::V1

  class TaskPlanStatsRepresenter < Roar::Decorator

    include Roar::JSON

    property :course,
      type: Object,
      readable: true,
      writeable: false,
      decorator: TaskPlanPeriodStatsRepresenter

    collection :periods,
      readable: true,
      writable: false,
      decorator: TaskPlanPeriodStatsRepresenter

  end
end
