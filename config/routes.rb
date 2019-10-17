Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get 'login', to: 'sessions#new', as: 'login'
  get 'signin', to: 'sessions#new', as: 'signin'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  post 'login', to: 'sessions#create', as: 'process_login'
  get 'search', to: 'product_search#index', as: 'product_search'
  resources :shelves do
    resources :products, controller: 'shelf_products'
  end
  root 'home#index'
end
