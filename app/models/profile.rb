class Profile < ApplicationRecord
  belongs_to :user
  has_one :github, dependent: :destroy

  after_initialize :set_defaults
  validates_each :social_links do |record, attr, value|
    value_dup = value.symbolize_keys
    valid_socials = get_valid_socials

    value_dup.each_key do |k|
      unless valid_socials.include?(k)
        record.errors.add(attr, "#{k} is not a valid social provider")
      end
    end
  end

  def set_defaults
    return unless new_record?

    self.tech_analysis ||= { repos: {} }
    self.tagline ||= ''
    self.social_links ||= {}
  end

  # class method for valid social providers (valid keys for social_links)
  def self.get_valid_socials
    %i[twitter facebook github stackoverflow dribble devto linkedin]
  end

  # base urls for user profiles for each provider
  # prepend 'https://' and append username/user-id to get full url
  def self.base_social_links
    {
      linkedin: 'linkedin.com/in/',
      devto: 'dev.to/',
      stackoverflow: 'stackoverflow.com/users/',
      dribbble: 'dribble.com/',
      facebook: 'facebook.com/',
      twitter: 'twitter.com/',
      github: 'github.com/'
    }
  end
end
