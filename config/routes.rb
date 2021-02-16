Rails.application.routes.draw do
  get 'home/index'
  get 'profiles/oauth/github', to: 'profiles/oauth_github#oauth_initiate'
  get 'profiles/oauth/github/callback', to: 'profiles/oauth_github#oauth_callback'
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'home#index'
end
