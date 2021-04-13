Rails.application.routes.draw do
  resources :bookmarks
  resources :blogs do
    member do
      put 'publish'
    end
  end
  get  'home/index'
  get  'profiles/oauth/github',
       to: 'profiles/oauth_github#oauth_initiate'
  get  'profiles/oauth/github/callback',
       to: 'profiles/oauth_github#oauth_callback'

  post 'internal/api/initial_analysis',
       to: 'analysis_endpoints/receive_analysis#receive_initial_analysis'
  post 'internal/api/tech_analysis',
       to: 'analysis_endpoints/receive_analysis#add_tech_analysis_by_repo'
  post 'internal/api/tech_analysis/status',
       to: 'analysis_endpoints/receive_analysis#tech_analysis_status'

  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    invitations: 'users/invitations',
    registrations: 'users/registrations'
  }, skip: [:registrations]

  as :user do
    put 'users' => 'users/registrations#update', :as => 'user_registration'
    delete 'users' => 'users/registrations#destroy', :as => 'user_delete'
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'home#index'

  # Each step is further described in the setup controller
  scope '/setup' do
    get '/', to: 'setup#index', as: 'setup'
    get '/1', to: 'setup#step_one', as: 'setup_step_one'
    get '/2', to: 'setup#step_two', as: 'setup_step_two'
    get '/3', to: 'setup#step_three', as: 'setup_step_three'
    get '/4', to: 'setup#step_four', as: 'setup_step_four'

    post '/1', to: 'setup#step_one_submit', as: 'setup_step_one_submit'
    post '/2', to: 'setup#step_two_submit', as: 'setup_step_two_submit'
    post '/3', to: 'setup#step_three_submit', as: 'setup_step_three_submit'
    post '/4', to: 'setup#step_four_submit', as: 'setup_step_four_submit'

    post '/previous_step', to: 'setup#previous_step', as: 'setup_previous_step'
  end

  scope '/internal/api' do
    post 'initial_analysis',
         to: 'analysis_endpoints/receive_analysis#receive_initial_analysis'
    post 'tech_analysis',
         to: 'analysis_endpoints/receive_analysis#add_tech_analysis_by_repo'
    post 'repo_analysis',
         to: 'analysis_endpoints/receive_analysis#repo_analysis'
  end

  scope '/data_api' do
    get '/user_info', to: 'data_api#user_info'
    get '/user_socials', to: 'data_api#user_socials'
    get '/projects', to: 'data_api#projects'
    get '/projects/:id', to: 'data_api#project_info'
    get '/projects/:project_id/repos/:repo_id', to: 'data_api#project_repo'
    get '/blogs', to: 'data_api#blogs'
    get '/blogs/:id', to: 'data_api#blog_info'
  end

  scope '/settings' do
    get '/profile', to: 'settings#profile'
    put '/profile', to: 'settings#profile_edit'
    put '/profile_social', to: 'settings#social_edit'
    put '/profile_contact_info', to: 'settings#contact_info_edit'
    get '/themes', to: 'settings#themes'
    put '/themes', to: 'settings#themes_edit'
    get '/account', to: 'settings#account'
    get '/password', to: 'settings#password'
  end

  scope '/projects' do
    get '/', to: 'projects#index', as: 'projects_home'
    get '/new', to: 'projects#new', as: 'project_new'
    put '/new', to: 'projects#create', as: 'project_create'
    get '/:id', to: 'projects#show', as: 'project'
    put '/:id', to: 'projects#update', as: 'update_project'
    get '/:id/edit', to: 'projects#edit', as: 'edit_project'
    delete '/:id', to: 'projects#delete', as: 'delete_project'
  end
end
