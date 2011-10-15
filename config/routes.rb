Securesign::Application.routes.draw do
  get 'logout' => 'sessions#destroy', as: 'logout'
  get 'login' => 'sessions#new', as: 'login'
  post 'login' => 'sessions#create', as: 'sessions'
  get 'signup' => 'users#new', as: 'signup'
  resources :users
  resources :sessions

  root to: 'info#index'
end
