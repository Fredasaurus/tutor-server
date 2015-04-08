require 'rails_helper'

RSpec.describe Api::V1::TaskSearchRepresenter, :type => :representer do

  context "a user" do

    let!(:user)           { FactoryGirl.create(:user_profile).entity_user }
    let!(:course)         { FactoryGirl.create(:entity_course) }
    let!(:role)           { Domain::AddUserAsCourseStudent.call(user: user,
                                                               course: course)
                                                         .outputs.role }
    let!(:default_task)   { FactoryGirl.create(:tasks_task) }
    let!(:task_count)     { rand(5..10) }
    let!(:tasks)          { task_count.times.collect {
      FactoryGirl.create(:tasks_task)
    } }
    let!(:taskings)       { tasks.collect { |t| FactoryGirl.create(
      :tasks_tasking, task: t.entity_task, role: role
    ) } }

    let!(:output)         { Hashie::Mash.new(
      'items' => Domain::GetCourseUserTasks[
        course: course, user: user
      ].collect{|t| t.task}
    ) }
    let!(:representation) { Api::V1::TaskSearchRepresenter.new(output).as_json }

    it "generates a JSON representation of their tasks" do
      expect(representation).to include(
        "total_count" => task_count,
        "items" => tasks.map{ | task |
          json = task.as_json.slice('id', 'title', 'task_plan_id')
          json['type']      = task.task_type
          json['opens_at']  = DateTimeUtilities.to_api_s(task.opens_at)
          json['due_at']    = DateTimeUtilities.to_api_s(task.due_at)
          json['is_shared'] = task.is_shared
          json['steps']     = task.task_steps.as_json
          json
        }
      )
    end

  end

end
