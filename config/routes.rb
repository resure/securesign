Securesign::Application.routes.draw do
  resources :users
  resources :sessions
  resources :keys
  resources :certificates
  resources :pages
  
  get 'logout' => 'sessions#destroy', as: 'logout'
  get 'login' => 'sessions#new', as: 'login'
  post 'login' => 'sessions#create', as: 'sessions'
  post 'users/:id' => 'users#destroy'
  get 'signup' => 'users#new', as: 'signup'
  
  get 'keys/:id/certificates' => 'keys#show_certificates', as: :key_certificates
  get 'certificates/:id/requests' => 'certificates#show_requests', as: :certificate_requests
  get 'certificates/:id/sign/:request_id' => 'certificates#show_request', as: :show_request
  post 'certificates/:id/sign/:request_id' => 'certificates#sign_request', as: :sign_request
  get 'certificates/:id/issued' => 'certificates#show_issued', as: :issued_certificates
  
  get 'signs/:id' => 'signs#show', as: :sign
  get 'signPage/:id' => 'signs#signing_page', as: :sign_page
  post 'signPage/:id' => 'signs#sign_page'
  
  get 'verifySign/:sha' => 'signs#verify_sign', as: :verify_sign
  get 'destroySign/:sha' => 'signs#destroy', as: :destroy_sign

  root to: 'info#index'
end
