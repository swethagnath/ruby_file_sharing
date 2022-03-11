require "cloudinary"

Cloudinary.config(
cloud_name: ENV['CLOUD_NAME'],
api_key:    ENV['CLOUD_API_KEY'],
api_secret: ENV['CLOUD_API_SECRET'],
)
