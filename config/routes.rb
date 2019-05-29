Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :auth do
        collection do
          post '/signup', to: "auth#signup"
          post '/login', to: "auth#login"
        end
      end
    end
  end


end
