require 'active_record'

unless $_api_root_path
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: File.join(__dir__,'./production.sqlite3'))
else
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: File.join($_api_root_path,'/database/production.sqlite3'))
end

class AddDelToCookmenuTable < ActiveRecord::Migration[5.2]
  def change
    add_column :cook_menus, :del, :boolean
  end
end

AddDelToCookmenuTable.migrate(:up)