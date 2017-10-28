module Api
  class UsersController < BaseController
    def index
      @users = User.all
      respond_with @users
    end

    def show
      @user = User.find(user_id)

      respond_with @user
    end

    def create
      @user = User.new(user_params)

      @user.save

      respond_with @user
    end

    def update
      @user = User.find(user_id)

      @user.update(user_params)

      respond_with @user
    end

    def destroy
      @user = User.find(user_id)

      @user.destroy

      respond_with @user
    end

    private

    def user_id
      params[:id].to_s
    end

    def user_params
      params.permit(:email, :username)
    end
  end
end
