require 'rails_helper'

RSpec.describe CourseProfile::Api::GetProfile do
  it 'outputs the profile by entity course id' do
    entity_course_id = Domain::CreateCourse.call.outputs.course.id

    profile = CourseProfile::Api::GetProfile.call(entity_course_id).outputs.profile

    expect(profile.course_id).to eq(entity_course_id)
  end
end
