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
    @base_social_links = Profile.base_social_links
    @social_links = current_user.profile.social_links.symbolize_keys
    @user = current_user
  end

  def step_three
    if current_user.setup_step != 3
      redirect_to("/setup/#{current_user.setup_step}")
    end
    @contact_info = current_user.profile.contact_info
    @user = current_user
  end

  def step_four
    if current_user.setup_step != 4
      redirect_to("/setup/#{current_user.setup_step}")
    end
    @valid_themes = Profile.valid_themes
    @current_theme = current_user.profile.theme
  end

  def step_one_submit
    current_user.setup_step = 2
    current_user.save
    redirect_to("/setup/#{current_user.setup_step}")
  end

  def step_two_submit
    profile = current_user.profile

    if profile.update!(social_params)
      current_user.setup_step = 3
      current_user.save
      redirect_to("/setup/#{current_user.setup_step}",
                  notice: 'Social Profiles Added Successfully')
    else
      redirect_to("/setup/#{current_user.setup_step}",
                  alert: 'Something went wrong. Please try again.')
    end
  end

  def step_three_submit
    profile = current_user.profile

    params_object = contact_info_params

    if params_object.dig('contact_info', 'phone')
      phone = Phonelib.parse(params_object.dig('contact_info', 'phone'))
      params_object[:contact_info][:phone] =
        if phone.country_code
          phone.international
        else
          phone.e164
        end
    end

    if profile.update(params_object)
      current_user.setup_step = 4
      current_user.save
      redirect_to "/setup/#{current_user.setup_step}",
                  notice: 'Contact Info Added'
    else
      redirect_to "/setup/#{current_user.setup_step}",
                  alert: profile.errors.full_messages.to_sentence
    end
  end

  def step_four_submit
    profile = current_user.profile
    theme = Theme.find(theme_params[:theme])
    if profile.update(theme: theme)
      profile.start_theme_build
      current_user.setup_step = 0
      current_user.save
      redirect_to('/projects', notice: 'Setup Completed Successfully!')
    else
      redirect_to "/setup/#{current_user.setup_step}",
                  alert: profile.errors.full_messages.to_sentence
    end
  end

  def previous_step
    current_user.setup_step -= 1
    current_user.save
    redirect_to("/setup/#{current_user.setup_step}")
  end

  private

  def social_params
    params.require(:profile).permit(:tagline,
                                    social_links: Profile.valid_socials)
  end

  def contact_info_params
    params.require(:profile).permit(contact_info: %i[email phone location])
  end

  def theme_params
    params.require(:theme).permit(:theme)
  end
end
