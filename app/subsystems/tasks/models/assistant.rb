class Tasks::Models::Assistant < Tutor::SubSystems::BaseModel

  has_many :course_assistants, dependent: :destroy

  has_many :task_plans, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :code_class_name, presence: true, uniqueness: true
  validate :code_class_existence, if: :code_class_name

  # Delegate all real work to the actual implementation (the "worker")
  delegate :schema, :build_tasks, to: :code_class

  protected

  def code_class_existence
    begin
      code_class
      true
    rescue NameError => e
      errors.add("#{code_class_name} does not exist")
      false
    end
  end

  def code_class
    @code_class ||= Kernel.const_get(code_class_name)
  end

end
