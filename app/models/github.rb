class Github < ApplicationRecord
  belongs_to :profile

  validates :uid, uniqueness: true
end
