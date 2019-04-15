Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  match 'index' => 'jview#index', via: [:get, :post] 
  
  match 'rules' => 'rules#index', via: [:get, :post] 

  root "jview#index", as: "root"

end
