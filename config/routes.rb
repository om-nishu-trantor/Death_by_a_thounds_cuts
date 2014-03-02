ParseRailsBoilerplate::Application.routes.draw do
  get "log_in" => "sessions#new", :as => "log_in"  
  get "log_out" => "sessions#destroy", :as => "log_out"  
  
  get "sign_up" => "users#new", :as => "sign_up"  
  root :to => "sessions#new"  
  resources :users  
  resources :sessions 
  namespace :api do
    resources :mailers do
      collection do
        post :send_mail
      end
    end    
  end
  resources :issues do
  	collection do
  		get :fetch_issue
  	end	
  end	
end
