class CreatePublicBookmarks < ActiveRecord::Migration[5.0]
  def change
      create_table :public_bookmarks do |t|
        t.string :title
        t.string :url
        t.text :description
        t.string :submitter_email
        t.timestamps
      end
      add_index :public_bookmarks, :url, unique: true
  end
end
