class Blog < ApplicationRecord
  belongs_to :profile

  extend FriendlyId
  friendly_id :title, use: :slugged

  validates :title, presence: true
  validates :profile, presence: true

  before_save do
    self.url ||= "#{profile.base_domain}/blogs/#{slug}"
    self.canonical_url ||= self.url
  end

  def readable_publish_date
    return nil unless published?

    if published_at.year == Time.zone.today.year
      published_at.strftime('%B %d')
    else
      published_at.strftime('%B %d, %Y')
    end
  end

  def publish
    if published?
      errors.add(:base, 'This blog has already been published')
    else
      self.published_at = DateTime.current
      save
    end
  end

  def published?
    !!published_at
  end

  def upload_cover_image(img_tf)
    response = Cloudinary::Uploader.upload(img_tf.to_io,
                                           folder: "users/#{profile.user_id}/blogs/cover_images/",
                                           public_id: id)
    self.cover_image = response.fetch('secure_url')
  end
end
