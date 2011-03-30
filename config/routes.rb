Csp::Application.routes.draw do
  root :to => "home#index"
  get  'violations' => 'home#get_violations'
  post 'violations' => 'home#set_violations'
end


