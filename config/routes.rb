Securesign::Application.routes.draw do
  resources :users
  resources :sessions
  resources :keys
  resources :certificates
  
  get 'logout' => 'sessions#destroy', as: 'logout'
  get 'login' => 'sessions#new', as: 'login'
  post 'login' => 'sessions#create', as: 'sessions'
  post 'users/:id' => 'users#destroy'
  get 'signup' => 'users#new', as: 'signup'
  
  get 'keys/:id/certificates' => 'keys#certificates', as: :key_certificates
  get 'certificates/:id/requests' => 'certificates#requests', as: :certificate_requests
  get 'certificates/:id/sign/:request_id' => 'certificates#show_request', as: :show_request
  post 'certificates/:id/sign/:request_id' => 'certificates#sign_request', as: :sign_request
  get 'certificates/:id/issued' => 'certificates#issued', as: :issued_certificates

  root to: 'info#index'
end
