require 'active_record'
unless $_api_root_path
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: './production.sqlite3')
else
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: File.join($_api_root_path,'/database/production.sqlite3'))
end


class CookMenu < ActiveRecord::Base
    self.table_name = "cook_menus"
    has_many :cook_images
    has_one :default_image
end


class CookImage < ActiveRecord::Base 
    self.table_name = 'cook_images'
    # belongs_to :cook_menu
    belongs_to :cook_menu
    belongs_to :default_image
end

class DefaultImage < ActiveRecord::Base
    self.table_name = "default_images"
    belongs_to :cook_menu
    has_one :cook_image
end

module WmyCookDB

    # 获取最新的feed,d倒序
    def self.last(num,offset=0)
        return Cmenu.order(:updated_at => :desc).offset(offset).first(num)
    end

end

# ActiveRecord::Base.allow_concurrency = true


