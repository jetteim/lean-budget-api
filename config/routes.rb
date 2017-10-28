Rails.application.routes.draw do
  namespace :api, except: %i[edit new], defaults: { format: :json }, path: '/' do
    resources :accounts
    resources :account_groups
    resources :categories
    resources :goals
    resources :users
    resources :user_profiles
    resources :sorted_transactions
    resources :sorting_rules
    resources :statements, only: %i[index show create destroy]
    resources :transactions do
      collection do
        post :sort
      end
    end
    resources :payments
    resources :tags, only: [:index]
    resources :balances, only: [:index] do
      collection do
        get :projected
      end
    end

    get 'statistics/activity_per_category'
    get 'statistics/activity_per_category_type'

    get 'options' => 'options#options'
    get 'options/account_types'
    get 'options/category_types'
    get 'options/goal_periods'
    get 'options/goal_types'
    get 'options/payment_types'
    get 'options/payment_periods'
  end
end
