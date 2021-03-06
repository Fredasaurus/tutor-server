class Content::Models::Exercise < Tutor::SubSystems::BaseModel
  acts_as_resource

  wrapped_by ::Exercise

  has_many :exercise_tags, dependent: :destroy
  has_many :tags, through: :exercise_tags

  has_many :tasked_exercises, subsystem: :tasks, primary_key: :url, foreign_key: :url

  # Exercises with the same number as this one, used to find the latest version below
  has_many :same_number, class_name: "Content::Models::Exercise",
                         primary_key: :number,
                         foreign_key: :number

  validates :number, presence: true
  validates :version, presence: true, uniqueness: { scope: :number }

  # First, join on the exercises with the same number to create a cartesian product,
  # then group by the primary key so we can use max()
  # and finally pick the row whose version matches the value of the max()
  scope :latest, -> { joins(:same_number)
                        .group(:id)
                        .having{version == max(same_number.version)} }

  def uid
    "#{number}@#{version}"
  end

  def tags_with_teks
    # Include tek tags
    tags.collect { |t| [t, t.teks_tags] }.flatten.uniq
  end
end
