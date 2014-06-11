BootstrapStarter::Application.routes.draw do




	#--------------------------------
	# all resources should be within the scope block below
	#--------------------------------
	scope ":locale", locale: /#{I18n.available_locales.join("|")}/ do

		match '/admin', :to => 'admin#index', :as => :admin, :via => :get
		devise_for :users, :path_names => {:sign_in => 'login', :sign_out => 'logout'},
											 :controllers => {:omniauth_callbacks => "omniauth_callbacks"}

		match '/admin/why_monitor', :to => 'admin#why_monitor', :as => :admin_why_monitor, :via => [:get, :post]

		namespace :admin do
			resources :users
      resources :disabilities
      resources :districts
      resources :question_categories do
        member do
          get 'questions'
          post 'questions'
        end
      end
      resources :questions
      resources :venues
      resources :venue_categories do
        member do
          get 'venues'
          post 'venues'
        end
      end
      resources :places do 
        collection do
          post 'address_search', :defaults => {:format => 'json'}
        end
      end
		end

    # add/view places
    resources :places, :only => [:show, :new, :create] do
      member do 
        get 'evaluation'
        put 'evaluation'
        get 'upload_photos'
        post 'upload_photos_post'
      end
      collection do
        post 'address_search', :defaults => {:format => 'json'}
      end
      match '/destroy_photo/:id', :to => 'places#destroy_photo', :as => :destroy_photo, :via => :delete
    end

    # user settings
		match '/settings', :to => 'settings#index', :as => :settings, :via => :get

    # methodology
		match '/methodology', :to => 'methodology#index', :as => :methodology, :via => :get
		match '/methodology/questions', :to => 'methodology#questions', :as => :methodology_questions, :via => :get
		match '/methodology/venues', :to => 'methodology#venues', :as => :methodology_venues, :via => :get
		match '/methodology/calculations', :to => 'methodology#calculations', :as => :methodology_calculations, :via => :get
    
    # why monitor
		match '/why_monitor', :to => 'root#why_monitor', :as => :why_monitor, :via => :get

		root :to => 'root#index'
	  match "*path", :to => redirect("/#{I18n.default_locale}") # handles /en/fake/path/whatever
	end

	match '', :to => redirect("/#{I18n.default_locale}") # handles /
	match '*path', :to => redirect("/#{I18n.default_locale}/%{path}") # handles /not-a-locale/anything

end
