require 'active_record'

unless $_api_root_path
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: './production.sqlite3')
else
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: File.join($_api_root_path,'/database/production.sqlite3'))
end

class CreateFimgeTable < ActiveRecord::Migration[5.2]
  def change
    create_table :cook_menus do |table|
        table.text      :contect
        # table.integer   :cook_images_id
        # table.integer   :default_image_id
        table.timestamps    
    end

    create_table :default_images do |table|
        table.integer :cook_menu_id
    end

    create_table :cook_images do |table|
      table.string :name
      table.integer :cook_menu_id, :null => false, :references => [:cook_menus, :id]
      table.integer :default_image_id,:references => [:default_images, :id]
      table.timestamps
    end

    
  end
end

# Create the table
CreateFimgeTable.migrate(:up)

# Drop the table
# CreateFimgeTable.migrate(:down)