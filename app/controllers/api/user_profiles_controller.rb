module Api
  class UserProfilesController < BaseController
    def index
      @user_profiles = UserProfile.all
      respond_with @user_profiles
    end

    def show
      @user_profile = UserProfile.find(user_profile_id)

      respond_with @user_profile
    end

    def create
      @user_profile = UserProfile.new(user_profile_params)

      @user_profile.save

      respond_with @user_profile
    end

    def update
      @user_profile = UserProfile.find(user_profile_id)

      @user_profile.update(user_profile_params)

      respond_with @user_profile
    end

    def destroy
      @user_profile = UserProfile.find(user_profile_id)

      @user_profile.destroy

      respond_with @user_profile
    end

    private

    def user_profile_id
      params[:id].to_s
    end

    def user_profile_params
      params.permit(:name, :telegram, :facebook, :google, :vk)
    end
  end
end
