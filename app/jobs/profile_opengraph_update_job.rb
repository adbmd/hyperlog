class ProfileOpengraphUpdateJob < ApplicationJob
  queue_as :default

  def perform(profile)
    profile.update_opengraph
  end
end
