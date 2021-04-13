json.extract! bookmark, :id, :profile_id, :url, :title, :folder, :is_pinned, :is_hidden, :to_read, :created_at, :updated_at
json.url bookmark_url(bookmark, format: :json)
