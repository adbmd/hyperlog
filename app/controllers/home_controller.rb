class HomeController < ApplicationController
  layout 'user'
  def index
    @profile = current_user.profile
  end
end
