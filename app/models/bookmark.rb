class Bookmark < ApplicationRecord
  belongs_to :profile

  # order by created date
  default_scope { order(created_at: :desc) }

  after_initialize :set_defaults

  validates :url,
            presence: true,
            format: /\A#{URI.DEFAULT_PARSER.make_regexp(%w[http https])}\z/
  validates :title, presence: true
  validates :folder, presence: true
  validates :is_hidden, presence: true
  validates :is_pinned, presence: true
  validates :to_read, presence: true

  private

  def set_defaults
    self.folder ||= ''
    self.is_hidden ||= false
    self.is_pinned ||= false
    self.to_read ||= false
  end
end
