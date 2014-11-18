Rails.application.routes.draw do
  
  namespace :api do
    namespace :v1 do
      resources :accounts do
        resources :transactions do
          collection do
            put 'withdraw'
            put 'deposit'
          end
        end
      end
    end
  end
end
