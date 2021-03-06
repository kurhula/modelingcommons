Nlcommons::Application.routes.draw do


  resources :attachments
  resources :versions
  resources :collaborator_types

  resources :projects do
    member do
      get 'download'
    end
  end

  match '/browse/model_contents/:dirname/:extensionname.:format' => 'browse#extension'

  match '/browse/:id/model_contents/' => 'browse#model_contents', :as => :model_contents

  match '/browse/:id/:extension/:extension.jar' => 'browse#extension', :as => :extension
  match '/browse/:id/:filename.:format' => 'browse#model_attachment', :as => :model_attachment
  match '/browse/:id/model_contents/:filename.:format' => 'browse#model_contents', :as => :model_attachment


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'account#mypage'

  # Need to specify size of preview image
  # If we use parameter string, then caches will ignore the size parameter, therefore we need to use the path 
  match 'browse/display_preview/:id/:size' => 'browse#display_preview'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id))(.:format)'
end
