class Theme < ApplicationRecord
  has_many :profiles, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
