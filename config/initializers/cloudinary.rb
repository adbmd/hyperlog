# frozen_string_literal: true

Cloudinary.config do |cloudinary|
  cloudinary.cloud_name = 'hyperlog'
  cloudinary.api_key = '817173125223939'
  cloudinary.api_secret = ENV['CLOUDINARY_API_SECRET']
  cloudinary.secure = true
  cloudinary.cdn_subdomain = true
end
