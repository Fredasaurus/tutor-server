class CreatePeriod
  lev_routine express_output: :period

  uses_routine CourseMembership::CreatePeriod,
    translations: { outputs: { type: :verbatim } },
    as: :create_period

  def exec(course:, name: nil)
    name ||= (course.periods.count + 1).ordinalize
    run(:create_period, course: course, name: name)
  end
end
