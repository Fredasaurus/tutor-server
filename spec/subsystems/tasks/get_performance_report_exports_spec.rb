require 'rails_helper'

RSpec.describe Tasks::GetPerformanceReportExports do
  it 'returns the export info related to courses' do
    AddUserAsCourseTeacher[course: Entity::Course.create!,
                           user: Entity::User.create!]

    course = Entity::Course.last
    role = Entity::Role.last

    physics_export = Tempfile.open(['Physics_I_Performance', '.xlsx']) do |physics_file|
      FactoryGirl.create(:performance_report_export,
                         export: physics_file,
                         course: course,
                         role: role)
    end

    biology_export = Tempfile.open(['Biology_I_Performance', '.xlsx']) do |biology_file|
      FactoryGirl.create(:performance_report_export,
                         export: biology_file,
                         course: course,
                         role: role)
    end

    export = described_class[course: course, role: role]

    # newest on top - enforced by default_scope in the model

    expect(export.length).to eq 2

    expect(export[0].filename).not_to include 'Biology_I_Performance'
    expect(export[0].filename).to include '.xlsx'
    expect(export[0].url).to eq biology_export.url
    expect(export[0].created_at).to be_the_same_time_as biology_export.created_at

    expect(export[1].filename).not_to include 'Physics_I_Performance'
    expect(export[1].filename).to include '.xlsx'
    expect(export[1].url).to eq physics_export.url
    expect(export[1].created_at).to be_the_same_time_as physics_export.created_at

  end
end
