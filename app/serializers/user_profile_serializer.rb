class UserProfileSerializer < ActiveModel::Serializer
  attributes :name, :telegram, :facebook, :google, :vk
end
