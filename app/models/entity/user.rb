class Entity::User < Tutor::SubSystems::BaseModel
  has_one :profile, subsystem: :user_profile

  has_many :role_user, class_name: '::Role::Models::User'
  has_many :roles, through: :role_user

  delegate :username, :first_name, :last_name, :full_name, to: :profile
end
