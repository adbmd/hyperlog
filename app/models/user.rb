class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, :confirmable,
         # omniauthable
         omniauth_providers: [:github],
         # confirmable
         reconfirmable: true, confirm_within: 24.hours

  # same github account shouldn't be connected twice
  validates :uid, uniqueness: { scope: :provider }, if: -> { !provider.nil? }

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

  def has_github_oauth
    provider == 'github'
  end

  def add_omniauth(auth)
    if auth.provider == 'github'
      # Add omniauth details to user unless the provider account is already
      # connected to another account
      unless self.class.where(provider: auth.provider, uid: auth.uid).exists?
        self.provider = auth.provider
        self.uid = auth.uid
        save
      end
    end
  end
end
