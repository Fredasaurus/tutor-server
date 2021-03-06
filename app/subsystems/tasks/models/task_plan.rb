require 'json-schema'

class Tasks::Models::TaskPlan < Tutor::SubSystems::BaseModel

  UPDATABLE_ATTRIBUTES = ['title', 'description']

  attr_writer :is_publish_requested

  # Allow use of 'type' column without STI
  self.inheritance_column = nil

  belongs_to :assistant
  belongs_to :owner, polymorphic: true

  has_many :tasking_plans, dependent: :destroy, inverse_of: :task_plan
  has_many :tasks, dependent: :destroy

  serialize :settings, JSON

  validates :title, presence: true
  validates :assistant, presence: true
  validates :owner, presence: true
  validates :type, presence: true
  validates :tasking_plans, presence: true

  validate :valid_settings, :changes_allowed, :not_due_before_publish

  before_destroy :not_open_before_destroy, prepend: true

  def tasks_past_open?
    tasks.any?{ |tt| tt.past_open? }
  end

  def is_publish_requested?
    !published_at.nil? || @is_publish_requested
  end

  protected

  def valid_settings
    schema = assistant.try(:schema)
    return if schema.blank?

    json_errors = JSON::Validator.fully_validate(schema, settings, insert_defaults: true)
    return if json_errors.empty?
    json_errors.each do |json_error|
      errors.add(:settings, "- #{json_error}")
    end
    false
  end

  def changes_allowed
    return if !tasks_past_open? || changes.except(*UPDATABLE_ATTRIBUTES).empty?
    errors.add(:base, "cannot be updated after it is open")
    false
  end

  def not_due_before_publish
    return if !is_publish_requested? || \
              tasking_plans.none? { |tp| !tp.due_at.nil? && tp.due_at < Time.now }
    errors.add(:due_at, 'cannot be in the past when publishing')
    false
  end

  def not_open_before_destroy
    return unless tasks_past_open?
    errors.add(:base, "cannot be deleted after it is open")
    false
  end

end
