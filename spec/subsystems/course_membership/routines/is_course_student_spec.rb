require 'rails_helper'

describe CourseMembership::IsCourseStudent do

  context "when not a student of the given course" do
    let(:target_course)       { Entity::CreateCourse.call.outputs.course }
    let(:other_course)        { Entity::CreateCourse.call.outputs.course }
    let(:target_student_role) { Entity::CreateRole.call.outputs.role }
    let(:other_student_role)  { Entity::CreateRole.call.outputs.role }

    before(:each) do
      CourseMembership::AddStudent.call(course: other_course,  role: target_student_role)
      CourseMembership::AddStudent.call(course: target_course, rols: other_student_role)
    end

    context "when a single role is given" do
      it "returns false" do
        result = CourseMembership::IsCourseStudent.call(course: target_course, roles: target_student_role)
        expect(result.errors).to be_empty
        expect(result.outputs.is_course_student).to be_falsey
      end
    end
    context "multiple roles are given" do
      it "returns false" do
        other_role1 = Entity::CreateRole.call.outputs.role
        other_role2 = Entity::CreateRole.call.outputs.role
        roles = [target_student_role, other_role1, other_role2]

        result = CourseMembership::IsCourseStudent.call(course: target_course, roles: roles)
        expect(result.errors).to be_empty
        expect(result.outputs.is_course_student).to be_falsey
      end
    end
  end

  context "when a student of the given course" do
    let(:target_course)       { Entity::CreateCourse.call.outputs.course }
    let(:target_student_role) { Entity::CreateRole.call.outputs.role }

    before(:each) do
      CourseMembership::AddStudent.call(course: target_course, role: target_student_role)
    end

    context "when a single role is given" do
      it "returns true" do
        result = CourseMembership::IsCourseStudent.call(course: target_course, roles: target_student_role)
        expect(result.errors).to be_empty
        expect(result.outputs.is_course_student).to be_truthy
      end
    end
    context "multiple roles are given" do
      it "returns true" do
        other_role1 = Entity::CreateRole.call.outputs.role
        other_role2 = Entity::CreateRole.call.outputs.role
        roles = [target_student_role, other_role1, other_role2]

        result = CourseMembership::IsCourseStudent.call(course: target_course, roles: roles)
        expect(result.errors).to be_empty
        expect(result.outputs.is_course_student).to be_truthy
      end
    end
  end

end