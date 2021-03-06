class GetTeacherNames
  lev_routine

  uses_routine GetCourseTeacherUsers,
    translations: { outputs: { type: :verbatim } },
    as: :get_teacher_users

  uses_routine UserProfile::GetUserFullNames,
    translations: { outputs: { map: {full_names: :teacher_names} } },
    as: :get_full_names

  protected

  def exec(course_id)
    course = Entity::Course.find(course_id)
    run(:get_teacher_users, course)
    run(:get_full_names, outputs[:teachers])
    outputs[:teacher_names] = outputs[:teacher_names].collect(&:full_name).sort
  end
end
