class SetupController < ApplicationController
  layout 'setup'
  def index
    @user = current_user
  end
end
