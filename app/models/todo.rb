class Todo < ApplicationRecord
  # Validations
  validates :title, presence: true, length: { minimum: 2, maximum: 100 }, uniqueness: true
  validates :description, length: { maximum: 500 }, allow_blank: true
  validates :completed, inclusion: { in: [true, false] }

  # Optional: Custom validation
  validate :title_cannot_be_all_numbers

  private

  def title_cannot_be_all_numbers
    if title.present? && title.match(/\A\d+\z/)
      errors.add(:title, "cannot be only numbers")
    end
  end
end