class Profile < ApplicationRecord
  include CableReady::Broadcaster

  belongs_to :user
  belongs_to :theme, dependent: nil

  has_one :github, dependent: :destroy

  has_many :profile_repo_analyses, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :repos, through: :profile_repo_analyses
  has_many :blogs, dependent: :destroy # set sentinel/null?

  after_initialize :set_defaults
  before_save :contact_info_attrs_nil_if_blank

  after_update :broadcast_progress, if: proc { analysis_status? }

  validates_each :social_links do |record, attr, value|
    value_dup = value.symbolize_keys
    valid_socials_hash = valid_socials

    value_dup.each_key do |k|
      unless valid_socials_hash.include?(k)
        record.errors.add(attr, "#{k} is not a valid social provider")
      end
    end
  end

  # allow a maximum of 5 projects per user
  validates :projects, length: { maximum: 5 }

  validate :validate_contact_info_email, :validate_contact_info_phone

  def set_defaults
    return unless new_record?

    self.theme ||= Theme.first
    self.tagline ||= ''
    self.social_links ||= {}
    self.contact_info ||= {
      email: nil,
      phone: nil,
      location: nil
    }
  end

  # class method for valid social providers (valid keys for social_links)
  def self.valid_socials
    %i[twitter facebook github stackoverflow dribbble devto linkedin]
  end

  # base urls for user profiles for each provider
  # prepend 'https://' and append username/user-id to get full url
  def self.base_social_links
    {
      linkedin: 'linkedin.com/in/',
      devto: 'dev.to/',
      stackoverflow: 'stackoverflow.com/users/',
      dribbble: 'dribbble.com/',
      facebook: 'facebook.com/',
      twitter: 'twitter.com/',
      github: 'github.com/'
    }
  end

  def self.valid_themes
    Theme.where(active: true).all
  end

  def start_theme_build
    url = Rails.configuration.x.profiles.theme_build_invocation_url
    basic_creds = Rails.configuration.x.profiles.theme_build_basic_auth

    conn = Faraday.new(url)
    conn.basic_auth(*basic_creds)
    conn.post do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = { uuid: user.id, username: user.username,
                   themeName: theme.name }.to_json
    end
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

  def base_domain
    "https://#{user.username}.hyperlog.dev"
  end

  private

  def validate_contact_info_email
    return if contact_info['email'].blank?

    unless URI::MailTo::EMAIL_REGEXP.match(contact_info['email'])
      errors.add(:contact_info, 'email is not valid')
    end
  end

  def validate_contact_info_phone
    return if contact_info['phone'].blank?

    if Phonelib.invalid?(contact_info['phone'])
      errors.add(:contact_info, 'phone number is invalid')
    end
  end

  def contact_info_attrs_nil_if_blank
    contact_info.each do |k, v|
      contact_info[k] = nil if v == ''
    end
  end

  def broadcast_progress
    cable_ready['progress'].morph(
      selector: '#' + ActionView::RecordIdentifier.dom_id(self),
      html: ApplicationController.render(partial: 'home/progress',
                                         locals: { profile: self })
    )
    cable_ready.broadcast
  end
end
