class AddScrapboxPageToTasks < ActiveRecord::Migration[6.1]
  def change
    add_column :tasks, :scrapbox_page, :string
  end
end
