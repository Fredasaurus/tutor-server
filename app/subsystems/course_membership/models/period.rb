class CourseMembership::Models::Period < Tutor::SubSystems::BaseModel
  wrapped_by ::Period

  belongs_to :course, subsystem: :entity

  has_many :teachers, through: :course
  has_many :teacher_roles, through: :teachers, source: :role, class_name: 'Entity::Role'

  has_many :enrollments, dependent: :destroy
  has_many :active_enrollments,
           -> (period) { period.enrollments.latest.active },
           class_name: '::CourseMembership::Models::Enrollment'

  has_many :taskings, subsystem: :tasks, dependent: :nullify
  has_many :tasks, through: :taskings

  before_destroy :no_active_students, prepend: true

  validates :course, presence: true
  validates :name, presence: true, uniqueness: { scope: :entity_course_id }

  default_scope { order(:name) }

  def student_roles
    active_enrollments.includes(student: :role).collect{ |en| en.student.role }
  end

  protected

  def no_active_students
    return unless enrollments.latest.active.exists?
    errors.add(:students, 'must be moved to another period before this period can be deleted')
    false
  end
end
