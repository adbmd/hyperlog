class CreateBlogs < ActiveRecord::Migration[6.1]
  def change
    create_table :blogs do |t|
      t.belongs_to :profile, index: true

      t.string :slug
      t.string :title
      t.string :description
      t.string :cover_image
      t.string :url
      t.string :canonical_url
      t.text :body_markdown
      t.jsonb :cross_posts
      t.datetime :published_at

      t.timestamps
    end
    add_index :blogs, :slug, unique: true
  end
end
