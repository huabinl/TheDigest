class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.references :source, index: true, foreign_key: true
      t.datetime :pub_date
      t.string :summary
      t.string :author
      t.string :image
      t.string :link

      t.timestamps null: false
    end
  end
end
