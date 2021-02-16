class Profile < ApplicationRecord
  belongs_to :user
  has_one :github, dependent: :destroy
end
