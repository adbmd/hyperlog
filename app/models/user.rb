class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :omniauthable,
         :confirmable,
         # authentication
         authentication_keys: [:login],
         # omniauthable
         omniauth_providers: [:github],
         # confirmable
         reconfirmable: true,
         confirm_within: 24.hours

  # same github account shouldn't be connected twice
  validates :uid, uniqueness: { scope: :provider }, if: -> { !provider.nil? }

  # case insensitive
  validates :username, presence: true, uniqueness: { case_sensitive: false }

  # @ character shouldn't be allowed in username (else it could be confused with email)
  validates :username, format: { with: /^[a-zA-Z0-9_.]*$/, multiline: true }

  # Add :login reader and writer for username/email authentication
  attr_writer :login

  def login
    @login || username || email
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
      where(email: auth.info.email).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.password = Devise.friendly_token[0, 20]
        user.skip_confirmation!
      end
    end
  end

  def has_github_oauth?
    provider == 'github'
  end

  def add_omniauth(auth)
    return if self.class.exists?(provider: auth.provider, uid: auth.uid)

    self.provider = auth.provider
    self.uid = auth.uid
    save
  end
end
