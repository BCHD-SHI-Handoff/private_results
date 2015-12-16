Rails.application.routes.draw do
  root to: 'online_results#index'
  post 'results', to: 'online_results#show'

  scope '/admin' do
    as :user do
        match '/user/confirmation' => 'confirmations#update', :via => :patch, :as => :update_user_confirmation
    end
    devise_for :users, :controllers => { :confirmations => "confirmations" }

    get "/", to: redirect('/admin/dashboards')
    resources :dashboards, only: [:index]

    resources :patients, only: [:index] do
      collection do
        get :export
      end
    end

    resources :clinics
    resources :scripts

    resources :users do
      member do
        get :send_reset_password
      end
    end
  end

  # Used by twilio.
  namespace :api, defaults: {format: 'xml'} do
    get 'welcome'
    get 'welcome_repeat'
    get 'welcome_process'

    get 'username_prompt'
    get 'username_prompt_repeat'
    get 'username_prompt_process'

    get 'password_prompt'
    get 'password_prompt_repeat'
    get 'password_prompt_process'

    get 'deliver_results'
    get 'repeat_message'
  end
end
