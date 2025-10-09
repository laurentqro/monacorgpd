class Questionnaire < ApplicationRecord
  # Enums
  enum :status, { draft: 0, published: 1, archived: 2 }, default: :draft

  # Associations
  belongs_to :account
  belongs_to :creator, class_name: "User", optional: true
  has_many :sections, dependent: :destroy
  has_many :responses, dependent: :destroy
  has_many :questions, through: :sections

  # Validations
  validates :title, presence: true, length: { maximum: 500 }
  validates :category, length: { maximum: 100 }, allow_blank: true
  validates :status, presence: true

  # Scopes
  scope :for_account, ->(account) { where(account: account) }
  scope :active, -> { where(deleted_at: nil) }
  scope :by_status, ->(status) { where(status: status) }

  # Soft delete
  def soft_delete
    update(deleted_at: Time.current)
  end

  def deleted?
    deleted_at.present?
  end

  def restore
    update(deleted_at: nil)
  end
end
