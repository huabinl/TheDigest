class CreateMails < ActiveRecord::Migration
  def change
    create_table :mails do |t|
      t.string :article_id
      t.string :user_id

      t.timestamps null: false
    end
  end
end
