require_relative 'cook_activerecord'

def test

    # puts WmyFeedDB::last(10).map {|e| e.to_json }
    # puts WmyFeedDB::last(10)[0].hash
    # puts WmyFeedDB::last(10)[0].public_methods.select {|e| e =~ /h/ }
    # relhash = {}
    # relhash['num'] = 2 
    # relhash['offset'] = 2
    # relhash['data'] = WmyFeedDB::last(2,2).map do |e| 
    #     JSON.parse(e.to_json)
    # end
    # relhash['status'] = true
    # puts relhash['data']
    # puts JSON.generate(relhash)

    ## create 
    cm = CookMenu.new 
    cf0 = CookImage.new 
    cf1 = CookImage.new

    cm.contect = "菜谱内容"
    cf0.name = "图片路径1"
    cf1.name = "图片路径2"
    # cm.default_image = cf0 
    cm.default_image = DefaultImage.new
    cm.default_image.cook_image = cf0
    cm.cook_images << cf0 
    cm.cook_images << cf1 
    cm.save 
end

test