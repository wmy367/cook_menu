
require "mini_magick"

def mini_show_trans(imagefile)
    image = MiniMagick::Image.open(imagefile) #打开一个图片，这会copy一个图像副本，改操作不会影响原图

    image[:height] # 1227 图片高度 px
    image[:width]  # 690 图片宽度 px

    if image[:height] > image[:width]
        shave_off = (image[:height] - image[:width])/2 
        image.shave "0x#{shave_off}" 
    else 
        shave_off = (image[:width] - image[:height])/2 
        image.shave "#{shave_off}x0" 
    end

    image.resize 165
    if $_api_root_path
        newpath = File.join($_api_root_path,"/cook_images/shave_#{File.basename(imagefile)}")
    else 
        newpath = File.join(__dir__,"../cook_images/shave_#{File.basename(imagefile)}")
    end
    image.write(newpath)
end


# def test
#     mini_show_trans('/home/wmy367/work/web/ele-note/feed_images/idle.png')
# end

# test
