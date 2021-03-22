class HomeController < ApplicationController
  layout 'user'
  def index
    @profile = current_user.profile
    @user = current_user
  end
end
