class CreateRoleRoleUsers < ActiveRecord::Migration
  def change
    create_table :role_role_users do |t|
      t.integer :entity_user_id, null: false
      t.integer :entity_role_id, null: false
      t.timestamps null: false

      t.index [:entity_user_id, :entity_role_id], unique: true, name: 'role_role_users_user_role_uniq'
    end

     add_foreign_key :role_role_users, :entity_users
     add_foreign_key :role_role_users, :entity_roles
  end
end
