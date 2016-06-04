PeakEHR::Application.routes.draw do

  resource :schedule do
    post :add_clinician
    get  :daysheet
  end

  resources :patients do
    resource :demographics, controller: 'patients/demographics'
    resources :medications, controller: 'patients/medications'
    resources :prescriptions, controller: 'patients/prescriptions' do
      collection do
        get :autocomplete
        get :check_suggested_dosing
      end
    end
    resources :enrollments, controller: 'patients/enrollments' do
      collection do
        get :check_eligibility
      end
    end
    resource :profile, controller: 'patients/profile'
  end

  get '/support' => 'support#index'
  post '/support' => 'support#create'

  resources :stamps, only: [ :index ]
  resources :dropboxes, only: [ :create ]
  resources :appointments

  resources :encounters, only: [ :create, :update, :delete ] do
    get :autocomplete
  end

  resources :letters
  resources :tasks
  resources :profile

  resource :session do
    get :setup_otp
    get :otp_qrcode, constraints: { format: :svg }
    get :api_tokens_qrcode, constraints: { format: :svg }
    put :set_working_under
    get :api_auth_test
  end

  get '/pair' => 'sessions#setup_api_tokens'
  resources :users

  controller :search do
    get :autocomplete
  end

  namespace :help do
    get :attach_photo
  end

  get '/subscribe' => 'event#index'
  root to: 'sessions#new'

end
