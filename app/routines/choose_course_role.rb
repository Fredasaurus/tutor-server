# If role_id provided:
#   make sure it belongs to user; fatal :invalid_role if not
#
# If role_id is not specified:
#   Get the users set of roles for the given course, restricted to
#   allowed_role_type unless that is set to :any (the default)
#
#   If there are no roles, fail with :invalid_user
#
#   If there is one role, return it
#
#   If there are multiple roles:
#     If one is a :teacher, return it
#     Otherwise fail with fatal_error code: multiple_roles
#
class ChooseCourseRole

  lev_routine express_output: :role

  uses_routine GetUserCourseRoles

  protected

  def exec(user:, course:, allowed_role_type: :any, role_id: nil)
    if role_id
      role = Entity::Role.find(role_id)
      fatal_error(code: :invalid_role, message:"Role not found") unless role
      validate_role_membership(course, user, role)
    else
      roles = GetUserCourseRoles[course:course, user:user, types:allowed_role_type]
      validate_role_listing(roles)
    end
  end

  private

  # the simplest case where we were given a role.
  # Verify the user has it on the course and return
  def validate_role_membership(course, user, role)
    if GetUserCourseRoles[course:course, user:user].include?(role)
      outputs[:role] = role
    else
      fatal_error(code: :invalid_role, message:"Invalid role for user in course")
    end
  end

  # Choose the "best" role from the list
  # of possible roles for the user
  def validate_role_listing(roles)
    if roles.none?
      fatal_error(code: :invalid_user, message:"The user does not have the specified role" )
    elsif roles.one?
      outputs[:role] = roles.first
    else
      teacher_role = roles.detect(&:teacher?)
      if teacher_role
        outputs[:role] = teacher_role
      else
        fatal_error(code: :multiple_roles, message:"The role must be specified because there is more than one student role available" )
      end
    end
  end


end