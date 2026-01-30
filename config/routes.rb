Rails.application.routes.draw do
  get 'pages/about'
  get 'pages/blog'
  get 'pages/contact'
  post 'pages/contact', to: 'pages#contact_submit'
  post 'subscribe', to: 'pages#subscribe'
  
  # Authentication routes
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  
  # OmniAuth routes - These should be BEFORE admin routes
  get '/auth/:provider/callback', to: 'sessions#omniauth'
  post '/auth/:provider/callback', to: 'sessions#omniauth'
  get '/auth/failure', to: 'sessions#omniauth_failure'
  
  # Admin routes
  namespace :admin do
    root 'dashboard#index'
    resources :products
    resources :orders, only: [:index, :show, :update]
    resources :users do
      post :toggle_admin, on: :member
    end
  end
  
  # Cart routes
  resource :cart, only: [:show] do
    delete :clear, on: :member
  end
  resources :cart_items, only: [:create, :update, :destroy]
  
  # Wishlist routes
  resources :wishlist_items, only: [:index, :create, :destroy]
  
  # Order and Payment routes
  resources :orders do
    get 'checkout', on: :member
    get 'payment_intent', on: :member
  end
  
  get 'payments/success', to: 'payments#success'
  post 'webhooks/stripe', to: 'payments#webhook'

  resources :messages, only: [:index, :show, :create]
  get 'chat', to: 'messages#chat', as: :chat
  
  # Mount Action Cable
  mount ActionCable.server => '/cable'

  resources :products
  resources :collections
  get 'shop', to: 'collections#index', as: 'shop'
  
  root 'home#index'
  get 'home/index'
  get 'home/show'
  get 'home/new'
end