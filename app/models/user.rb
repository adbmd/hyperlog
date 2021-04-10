class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable,
         :rememberable,
         :validatable,
         :omniauthable,
         :confirmable,
         :registerable,
         # authentication
         authentication_keys: [:login],
         # omniauthable
         omniauth_providers: [:github],
         # confirmable
         reconfirmable: true,
         confirm_within: 24.hours

  has_one :profile, dependent: :destroy

  after_initialize :set_defaults

  # same github account shouldn't be connected twice
  validates :uid, uniqueness: { scope: :provider }, if: -> { !provider.nil? }

  # case insensitive
  validates :username, presence: true, uniqueness: { case_sensitive: false }

  # first name and last name
  validates :first_name, presence: true
  validates :last_name, presence: true

  # @ character shouldn't be allowed in username (else it could be confused with email)
  validates :username, format: { with: /^[a-z0-9-]*$/, multiline: true }

  # validate email with regex
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_validation do
    self.username = username.downcase if username?
  end

  before_save :update_opengraph_image_if_needed

  # Add :login reader and writer for username/email authentication
  attr_writer :login

  def login
    @login || username || email
  end

  def set_defaults
    return unless new_record?

    self.username_confirmed = true if username_confirmed.nil?
    self.profile ||= Profile.new
  end

  # overwrite the default
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h)
        .where(
          [
            'lower(username) = :value OR lower(email) = :value',
            { value: login.downcase }
          ]
        )
        .first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      conditions[:email].downcase! if conditions[:email]
      where(conditions.to_h).first
    end
  end

  def self.from_omniauth(auth)
    if auth.provider == 'github'
      # if provider-uid exists return that user
      # else see if the primary_email is associated with another user
      # if yes, return that user (without adding provider-uid)
      # else create a new user with the fetched details

      # fetch and return user with provided github details if present
      user = where(provider: auth.provider, uid: auth.uid).first
      return user if user

      # return user with that email id or create a new user
      # where(email: auth.info.email).first_or_create do |user|
      #   split_name = lambda do |name|
      #     ret = name.split(/ /, 2)
      #     return ret if ret.length == 2

      #     [ret[0], '']
      #   end

      #   generate_username = lambda do |nick|
      #     if exists?(username: nick)
      #       100.times do
      #         candidate = "#{nick}-#{SecureRandom.hex(5)}"
      #         return candidate unless exists?(username: candidate)
      #       end
      #       # Something is really wrong if 100 tries weren't enough
      #       raise 'Unable to assign a random username'
      #     else
      #       nick
      #     end
      #   end

      #   user.first_name, user.last_name = split_name.call(auth.info.name)
      #   user.username = generate_username.call(auth.info.nickname)
      #   user.username_confirmed = false # allow user to edit username later
      #   user.provider = auth.provider
      #   user.uid = auth.uid
      #   user.password = Devise.friendly_token[0, 20]
      #   user.skip_confirmation!
      # end
    end
  end

  def has_github_oauth?
    provider == 'github'
  end

  def add_omniauth(auth)
    return if self.class.exists?(provider: auth.provider, uid: auth.uid)
    return unless provider.nil?

    self.provider = auth.provider
    self.uid = auth.uid
    save
  end

  private

  def update_opengraph_image_if_needed
    unless (changed_attribute_names_to_save & %w[first_name last_name avatar_url]).any?
      return
    end

    profile.update_opengraph
  end
end
