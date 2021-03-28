class UserMailer < Devise::Mailer
  default reply_to: Rails.configuration.x.users.mailer_reply_to
end
  