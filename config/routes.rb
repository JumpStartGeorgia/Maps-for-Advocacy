BootstrapStarter::Application.routes.draw do


	#--------------------------------
	# all resources should be within the scope block below
	#--------------------------------
	scope ":locale", locale: /#{I18n.available_locales.join("|")}/ do

		match '/admin', :to => 'admin#index', :as => :admin, :via => :get
		devise_for :users, :path_names => {:sign_in => 'login', :sign_out => 'logout'},
											 :controllers => {:omniauth_callbacks => "omniauth_callbacks"}

		namespace :admin do
      resources :question_pairing_disabilities, :path => "help_text"
      resources :training_videos
      resources :organizations
      resources :rights
      resources :convention_categories
      resources :pages
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
    match '/places/saw_popup', :to => 'places#saw_popup', :as => :saw_popup, :via => :post, :defaults => {:format => :js}
    resources :places do
      member do 
        get 'evaluation'
        put 'evaluation'
      end
      collection do
        post 'address_search', :defaults => {:format => 'json'}
      end
    end
    match '/places/:id/delete_evaluation/:evaluation_id', :to => 'places#delete_evaluation', :as => :delete_place_evaluation, :via => :delete
    match '/places/:id/evaluation_details/:is_certified(/:type)', :to => 'places#evaluation_details', :as => :place_evaluation_details, :via => :get


    # user settings
		match '/settings', :to => 'settings#index', :as => :settings, :via => :get

    # print questions
		match '/print', :to => 'print#index', :as => :print, :via => :get
		
		# manage org users
		match '/manage_users', :to => 'manage_users#index', :as => :manage_users, :via => :get
		match '/manage_users/delete/:organization_id/:user_id', :to => 'manage_users#delete', :as => :delete_manage_users, :via => :delete
		match '/manage_users/add/:organization_id', :to => 'manage_users#add', :as => :add_manage_users, :via => :get
		match '/manage_users/add/:organization_id/:user_id', :to => 'manage_users#add_user', :as => :add_new_manage_users, :via => :get

    # methodology
		match '/methodology', :to => 'methodology#index', :as => :methodology, :via => :get
		match '/methodology/questions', :to => 'methodology#questions', :as => :methodology_questions, :via => :get
#		match '/methodology/venues', :to => 'methodology#venues', :as => :methodology_venues, :via => :get
    match '/methodology/categories', :to => 'methodology#categories', :as => :methodology_categories, :via => :get
		match '/methodology/calculations', :to => 'methodology#calculations', :as => :methodology_calculations, :via => :get
    
    # root pages
    match '/about', :to => 'root#about', :as => :about, :via => :get
    match '/contact', :to => 'root#contact', :as => :contact, :via => :get
    match '/find_places', :to => 'root#find_places', :as => :find_places, :via => :get
		match '/un_crpd', :to => 'root#un_crpd', :as => :un_crpd, :via => :get
		match '/georgian_legislation', :to => 'root#georgian_legislation', :as => :georgian_legislation, :via => :get
		match '/why_monitor', :to => 'root#why_monitor', :as => :why_monitor, :via => :get
#		match '/partners', :to => 'root#partners', :as => :partners, :via => :get
		match '/what_is_accessibility', :to => 'root#what_is_accessibility', :as => :what_is_accessibility, :via => :get
    match '/video_guides', :to => 'root#video_guides', :as => :video_guides, :via => :get
    match '/video_guides/:id', :to => 'root#video_guide', :as => :video_guide, :via => :get
    match '/video_guides/:id/record_video_guide_progress', :to => 'root#record_video_guide_progress', :as => :record_video_guide_progress, :via => :post, :defaults => {:format => :js}
    match '/stats', :to => 'root#stats', :as => :stats, :via => :get

		root :to => 'root#index'
	  match "*path", :to => redirect("/#{I18n.default_locale}") # handles /en/fake/path/whatever
	end

	match '', :to => redirect("/#{I18n.default_locale}") # handles /
	match '*path', :to => redirect("/#{I18n.default_locale}/%{path}") # handles /not-a-locale/anything

end
