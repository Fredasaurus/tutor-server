require 'rails_helper'

describe Role::AddUserRole do
  context "when adding a new user role" do
    it "succeeds" do
      role = Entity::Role.create!
      user = Entity::User.create!

      result = nil
      expect {
        result = Role::AddUserRole.call(user: user, role: role)
      }.to change { Role::Models::RoleUser.count }.by(1)
      expect(result.errors).to be_empty
    end
  end
  context "when adding a existing user role" do
    it "fails" do
      role = Entity::Role.create!
      user = Entity::User.create!

      result = nil
      expect {
        result = Role::AddUserRole.call(user: user, role: role)
      }.to change { Role::Models::RoleUser.count }.by(1)
      expect(result.errors).to be_empty

      expect {
        result = Role::AddUserRole.call(user: user, role: role)
      }.to raise_error
    end
  end
end
