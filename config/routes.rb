Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :auth, only: [] do
        collection do
          post '/signup/staff', to: "auth#signup"
          post '/login/hod', to: "auth#hod_login"
          post '/login/librarian', to: "auth#librarian_login"
          post '/login/incharge', to: "auth#incharge_login"
          post '/login/staff', to: "auth#staff_login"
        end
      end
    end
  end


end
