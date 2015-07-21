require 'rails_helper'

RSpec.describe Api::V1::StudentRepresenter, type: :representer do
  let!(:user) { FactoryGirl.create(:user_profile).entity_user }
  let!(:period) { FactoryGirl.create(:period) }
  let!(:student) {
    AddUserAsPeriodStudent.call(period: period, user: user).outputs.student
  }

  it 'represents a student' do
    representation = Api::V1::StudentRepresenter.new(student).as_json
    expect(representation).to eq(
      'id' => student.id.to_s,
      'period_id' => period.id.to_s,
      'role_id' => student.role.id.to_s,
      'first_name' => student.first_name,
      'last_name' => student.last_name,
      'full_name' => student.full_name,
      'deidentifier' => student.deidentifier
    )
  end
end
