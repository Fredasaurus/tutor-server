require 'rails_helper'

describe Role::GetUserRoles do
  context "there are no roles for the given user" do
    it "returns an empty array" do
      target_user = Entity::User.create!
      other_user  = Entity::User.create!
      role        = Entity::Role.create!

      Role::AddUserRole.call(user: other_user, role: role)

      result = Role::GetUserRoles.call(target_user)

      expect(result.errors).to be_empty
      expect(result.outputs.roles).to be_empty
    end
  end
  context "there is one role for the given user" do
    it "returns that role" do
      target_user = Entity::User.create!
      target_role = Entity::Role.create!

      other_user  = Entity::User.create!
      other_role  = Entity::Role.create!

      Role::AddUserRole.call(user: target_user, role: target_role)
      Role::AddUserRole.call(user: other_user,  role: other_role)

      result = Role::GetUserRoles.call(target_user)

      expect(result.errors).to be_empty
      expect(result.outputs.roles.size).to eq(1)
      expect(result.outputs.roles).to include(target_role)
    end
  end
  context "there are multiple roles for the given user" do
    it "returns all user roles" do
      target_user  = Entity::User.create!
      target_role1 = Entity::Role.create!
      target_role2 = Entity::Role.create!

      other_user   = Entity::User.create!
      other_role   = Entity::Role.create!

      Role::AddUserRole.call(user: target_user, role: target_role1)
      Role::AddUserRole.call(user: target_user, role: target_role2)
      Role::AddUserRole.call(user: other_user,  role: other_role)

      result = Role::GetUserRoles.call(target_user)

      expect(result.errors).to be_empty
      expect(result.outputs.roles.size).to eq(2)
      expect(result.outputs.roles).to include(target_role1)
      expect(result.outputs.roles).to include(target_role2)
    end

    xit "returns limited types when requested" do
      # implemente me
    end
  end
end
