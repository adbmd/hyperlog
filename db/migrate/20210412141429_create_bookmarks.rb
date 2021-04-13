class CreateBookmarks < ActiveRecord::Migration[6.1]
  def change
    create_table :bookmarks do |t|
      t.belongs_to :profile, null: false, foreign_key: true
      t.string :url
      t.string :title
      t.string :folder
      t.boolean :is_pinned
      t.boolean :is_hidden
      t.boolean :to_read

      t.timestamps
    end
  end
end
