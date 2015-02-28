require 'rails_helper'

describe Role::AddUserRole do
  context "when adding a new user role" do
    it "succeeds" do
      role = Entity::CreateRole.call.outputs.role
      user = Entity::CreateUser.call.outputs.user

      result = nil
      expect {
        result = Role::AddUserRole.call(user: user, role: role)
      }.to change{Role::User.count}.by(1)
      expect(result.errors).to be_empty
    end
  end
  context "when adding a existing user role" do
    it "fails" do
      role   = Entity::CreateRole.call.outputs.role
      user = Entity::CreateUser.call.outputs.user

      result = nil
      expect {
        result = Role::AddUserRole.call(user: user, role: role)
      }.to change{Role::User.count}.by(1)
      expect(result.errors).to be_empty

      expect {
        result = Role::AddUserRole.call(user: user, role: role)
      }.to_not change{Role::User.count}
      expect(result.errors).to_not be_empty
    end
  end
end