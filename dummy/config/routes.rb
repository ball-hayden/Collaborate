Rails.application.routes.draw do

  resources :documents, only: [:index, :show, :create, :destroy]
end
