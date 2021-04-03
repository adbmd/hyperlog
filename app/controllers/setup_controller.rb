# This file contains 4 steps for the user.
#
# Step one: Connect with Github
# Step Two: Enter user information
# Step Three: Enter about field data
# Step four: Select a theme
#
# Upon Successfully completing everything, user would be redirected to the
# projects page.
class SetupController < ApplicationController
  layout 'setup'

  def index
    if current_user.setup_step.positive?
      redirect_to("/setup/#{current_user.setup_step}")
    else
      redirect_to '/', alert: 'Setup Already Completed'
    end
  end

  def step_one
    if current_user.setup_step != 1
      redirect_to("/setup/#{current_user.setup_step}")
    end
  end

  def step_two
    if current_user.setup_step != 2
      redirect_to("/setup/#{current_user.setup_step}")
    end
  end

  def step_three
    if current_user.setup_step != 3
      redirect_to("/setup/#{current_user.setup_step}")
    end
  end

  def step_four
    if current_user.setup_step != 4
      redirect_to("/setup/#{current_user.setup_step}")
    end
  end

  def step_one_submit
    current_user.setup_step = 2
    current_user.save
    redirect_to("/setup/#{current_user.setup_step}")
  end

  def step_two_submit
    current_user.setup_step = 3
    current_user.save
    redirect_to("/setup/#{current_user.setup_step}")
  end

  def step_three_submit
    current_user.setup_step = 4
    current_user.save
    redirect_to("/setup/#{current_user.setup_step}")
  end

  def step_four_submit
    current_user.setup_step = 0
    current_user.save
    redirect_to('/projects', notice: 'Setup Completed Successfully!')
  end

  def previous_step
    current_user.setup_step -= 1
    current_user.save
    redirect_to("/setup/#{current_user.setup_step}")
  end
end
