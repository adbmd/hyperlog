json.extract! blog, :id, :slug, :title, :description, :cover_image, :readable_publish_date, :social_image, :url, :canonical_url, :hosted_on, :body_html, :body_markdown, :created_at, :updated_at
json.url blog_url(blog, format: :json)
