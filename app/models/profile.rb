class Profile < ApplicationRecord
  include CableReady::Broadcaster

  belongs_to :user

  has_one :github, dependent: :destroy

  has_many :profile_repo_analyses, dependent: :destroy
  has_many :projects, dependent: :destroy

  after_initialize :set_defaults

  after_update do
    cable_ready['progress'].morph(
      selector: '#' + ActionView::RecordIdentifier.dom_id(self),
      html: ApplicationController.render(partial: 'home/progress',
                                         locals: { profile: self })
    )
    cable_ready['progress'].console_log(message: 'SOMETHING UPDATED')
    cable_ready.broadcast
  end

  validates_each :social_links do |record, attr, value|
    value_dup = value.symbolize_keys
    valid_socials = get_valid_socials

    value_dup.each_key do |k|
      unless valid_socials.include?(k)
        record.errors.add(attr, "#{k} is not a valid social provider")
      end
    end
  end

  validates :projects, length: { maximum: 5 }

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

  def update_analysis_status
    self.analysis_status = {
      repos_count: profile_repo_analyses.size,
      analysed_repos_count: profile_repo_analyses
                           .where.not(tech_analysis: nil)
                           .size,
      current_repo: nil,
      updated_at: Time.current.to_formatted_s(:iso8601)
    }
    save!
  end

  def analysis_completed?
    return false if analysis_status.nil?

    analysed, total = analysis_status.values_at('analysed_repos_count',
                                                'repos_count')
    analysed == total
  end

  private

  def set_defaults
    return unless new_record?

    self.tagline ||= ''
    self.social_links ||= {}
  end
end
