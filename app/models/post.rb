require "cloudinary"

class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :title, type: String
  field :description, type: String
  field :cloudinary_id, type: String
  field :file_name, type: String
  field :shorturl, type: String
  field :urlcode, type: String
  field :image, type: String
  field :public_access, type: Boolean
  field :private_users, type: Array

  validates :title,:description, :presence => true
  belongs_to :user
  
end
