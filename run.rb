$_api_root_path = File.dirname(__FILE__)

require 'sinatra'
require 'fileutils'
require_relative './database/cook_activerecord'
require 'sass'
require_relative "./magick/image_proc"
require 'yaml'
require 'sinatra/log'
require "image_optimizer"
require "thread"
require 'net/http/post/multipart'

$tdl = Mutex.new

$user_params = YAML::load(File.open(File.join($_api_root_path,"./pass.yml")))
$user_encrypt = {}
def trueYamlUserQ(user,pass)
    $user_params['users'].each do |k,v|
        if user.to_s == k.to_s && pass.to_s == v.to_s
            return true 
        end
    end
    return false
end

def trueYamlUserDirect(user,pass)

    if user.to_s == "wmy367" && pass.to_s == "wmy8356527"
        return true 
    else
        return false
    end
end

['cook_images','log'].each do |e|
    unless File.exist? File.join($_api_root_path,e)
        Dir::mkdir File.join($_api_root_path,e)
    end
end


class Mylog
    def self.log
        @logger ||= Sinatra::Log.new(:logger_name => 'ele-note',
                                    :log_filename => File.join($_api_root_path,'./log/development.log'),
                                    :loglevel => 'INFO',
                                    :enabled => true,
                                    :project_dir => '~/')
    end
end

class LoginScreen < Sinatra::Base
    enable :sessions
    set :public_folder, File.dirname(__FILE__) + '/static'
    # set :views, ['static']
    # set :views, ['views']
    # set :views, ['dist']

    # get('/login') do
    #     # erb :login_b,:layout => :base
    #     # erb :jqm_login,:layout => :jqm_main
    #     erb "",:layout => :ele_login,:locals => {id_name: "login"}
    # end

    post "/acklogin" do 
        unless session['user_name']
            JSON.generate({status: false,noLogin: true})
        else 
            unless $user_encrypt.values.include?(session['user_name'])
                JSON.generate({status: false,noLogin: true})
            else 
                JSON.generate({status: true,noLogin: false})
            end
        end
    end

    get "/login" do 
        JSON.generate({status: false,noLogin: true})
    end
  
    post('/login') do
        if trueYamlUserDirect params['name'],params['nick']
            $user_encrypt[params['name']] = SecureRandom.urlsafe_base64
            session['user_name'] = $user_encrypt[params['name']]

            Mylog::log.info params
            Mylog::log.info session['user_name']
            # redirect "/"
            JSON.generate({status: true})
        else
            Mylog::log.info "=====ERROR====="
            Mylog::log.info params
            # redirect '/login'
            JSON.generate({status: false})
        end
        
        # redirect "/"
    end

end


def findMenus(*args)
    puts args
    if args.empty? 
        return CookMenu.order(:updated_at => :desc).offset(0).first(1000)
    else 
        rels = []
        CookMenu.find_each do |e|
            index = 0
            score = 0
            cm = e
            args.each do |a|
                contect = '无'
                if !cm.contect || cm.contect.size==0
                    contect = cm.cook_images.map do |e|
                        e.ai_contect.to_s
                    end.join(' ')
                else 
                    contect = cm.contect
                end
                
                if contect.include? a
                    score += (args.size - index)
                end
                index += 1
            end

            if score != 0
                rels << [score,e]
            end
        end

        rels.sort! do |x,y|
            y[0] <=> x[0]
        end

        rels.map do |e|
            e[1]
        end
    end
end

$upload_images_hash = {}
$database_hash = {}
$star_collect = [] #menu id

def get_ai_contect(image_path)
    url = URI.parse('http://127.0.0.1:30001/')
    File.open(image_path) do |jpg|
        req = Net::HTTP::Post::Multipart.new url.path,"file" => UploadIO.new(jpg, "image")
        contect = ''
        begin
            res = Net::HTTP.star(url.host, url.port) do |http|
                contect =  http.request(req).body
            end
        rescue 
            contect = "AI识别异常"
        end
        puts contect

        # puts res.response
        if contect =~ /<div>(?<cc>.+)<\/div>/m
            return $~[:cc]
        else 
            return ''
        end
    end
end

class MyApp < Sinatra::Application

    # use LoginScreen
    # use WmyFeedApp::Feed

    # set :bind,"127.0.0.1"
    set :bind,"0.0.0.0"
    # set :public_folder, File.join(File.dirname(__FILE__),'/public/dist')
    set :public_folder, File.join(File.dirname(__FILE__),'/public/')
    set :port,8090
    # set :views, ['static','views']
    # set :views, ['views',"scss"]
    # set :views, ['dist']
    set :default_encoding,"utf-8"
    set :views, :scss => 'scss', :default => 'views'

    helpers do
        def find_template(views, name, engine, &block)
            _, folder = views.detect { |k,v| engine == Tilt[k] }
            folder ||= views[:default]
            super(folder, name, engine, &block)
        end
    end

    # before do
    #     unless session['user_name']
            
    #         halt erb "",layout: :ele_main,locals:{id_name:"app"}
    #     else 
    #         unless $user_encrypt.values.include?(session['user_name'])
    
    #             halt erb "",layout: :ele_main,locals:{id_name:"app"}
    #         end
    #     end
    # end

    get '/' do
        
        erb "",layout: :cook_main,locals:{id_name:"app"}
    end

    # get "/css/feeds.css" do 
    #     scss :feeds
    # end

    ## 上传  文件
    post '/cook_images' do 

        filepath = params['file']['tempfile']

        bn =  File.basename(filepath)

        str = File.open(filepath,'rb').read

        origin_image = File.join($_api_root_path,"/cook_images/#{bn}")

        File.open(origin_image,"wb") do |f|
            f.print(str)
        end

        Thread.new do 
            ImageOptimizer.new(origin_image, quality: 75, level: 2).optimize
            contect = get_ai_contect(origin_image)
            contect = contect.force_encoding("UTF-8")
            if $database_hash[origin_image]
                obj = CookImage.find_by_name(origin_image)
                puts "AI 滞后"
                if obj 
                    obj.ai_contect = contect
                    obj.save 
                    $database_hash[origin_image] = nil
                    puts "保存成功"
                end
            else
                $upload_images_hash[origin_image] = contect
            end
        end
        # ImageOptimizer.new(origin_image, quality: 75, level: 2).optimize
        # ImageOptimizer.new(origin_image).optimize

        mini_show_trans(origin_image)
        # sleep(4)
        JSON.generate({status: true,image_file: File.basename(filepath)})
    end

    post "/create_menu" do 
        params

        cm = CookMenu.new 
        cfs = []
        # puts params['files']
        # ((params['files'].is_a?(Array) && params['files']) || [params['files']]).each do |fn|
        params['files'].split(',').each do |fn|
            # puts fn
            cf0 = CookImage.new 
            cf0.name = File.join($_api_root_path,"/cook_images/#{fn}")

            if $upload_images_hash[cf0.name]
                cf0.ai_contect = $upload_images_hash[cf0.name]
                $upload_images_hash[cf0.name]
            else 
                $database_hash[cf0.name] = cf0
            end

            cfs << cf0 
        end

        cm.default_image = DefaultImage.new
        cm.default_image.cook_image = cfs[0]
        cm.contect = params['contect']
        cm.cook_images = cfs
        cm.save

        path = cm.default_image.cook_image.name
        new_path = File.join("/images","shave_#{File.basename(path)}")

        rel = {
            contect: cm.contect,
            path: new_path,
            id: cm.id,
            status: true
        }
        JSON.generate(rel)
    end

    post "/menus" do 
        # cms = CookMenu.order(:updated_at => :desc).offset(0).first(1000)
        # puts params
        if params['args']
            args_str = params['args']
            args = args_str.split(/[,|;|\s]/)
        else
            args = []
        end

        cms = findMenus(*args)

        rels = []

        cms.each do |cm|
            unless cm.default_image.cook_image
                next 
            end
            path = cm.default_image.cook_image.name
            new_path = File.join("/images","shave_#{File.basename(path)}")
            contect = '无'
            if !cm.contect || cm.contect.size==0
                contect = cm.cook_images.map do |e|
                    e.ai_contect.to_s
                end.join(' ')
            else 
                contect = cm.contect
            end

            rels << {
                star: $star_collect.include?(cm.id),
                contect: contect,
                path: new_path,
                id: cm.id
            }
        end

        JSON.generate(rels)
    end

    ## 获取图片
    get "/images/:name" do 
        fn = File.join($_api_root_path,"/cook_images/#{params['name']}")
        if(File.exist? fn)
            send_file fn
        else
            # send_file File.join($_api_root_path,"/static/images/idle.png")
            ''
        end
    end
    ##获取logo
    get "/logo.jpeg" do 
        send_file File.join($_api_root_path,"/public/logo.jpeg")
    end

    ## 获取单个菜谱
    post "/singleMenu" do 
        menu_id = params['id']
        obj = CookMenu.find(menu_id)

        unless obj 
            JSON.generate({'status': false, 'info': "没有找到对象"})
        else 
            images_url_path = obj.cook_images.map do |h|
                "/images/"+File.basename(h.name)
            end

            images_sv_url_path = obj.cook_images.map do |h|
                "/images/shave_"+File.basename(h.name)
            end
            images = obj.cook_images.map do |h|

                {
                    id: h.id,
                    path: "/images/"+File.basename(h.name),
                    sv_path: "/images/shave_"+File.basename(h.name)
                }
            end

            contect = '无'
            cm = obj
            if !cm.contect || cm.contect.size==0
                contect = cm.cook_images.map do |e|
                    e.ai_contect.to_s
                end.join(' ')
            else 
                contect = cm.contect
            end

            rels = {
                status: true,
                id: obj.id,
                star: $star_collect.include?(obj.id),
                contect: contect,
                images: images,
                default_image:{
                    id: obj.default_image.id,
                    path: "/images/" + obj.default_image.cook_image.name,
                    sv_path: "/images/shave_" + obj.default_image.cook_image.name
                }
            }
            JSON.generate( rels )
        end
    end

    ## 收藏
    post "/star_menu" do 
        puts params
        if params['star'] && !$star_collect.include?(params['menu_id'].to_i)
            $star_collect << params['menu_id'].to_i
            if $star_collect.size > 8
                $star_collect = $star_collect[$star_collect.size-8,8]
            end
        end 

        if !params['star'] 
            $star_collect.reject! do |e|
                e == params['menu_id'].to_i
            end
        end
        
        # puts $star_collect
        JSON.generate( {'status': true ,'star_memus': $star_collect})
    end

    post "/get_star_menus" do 
        # cms = findMenus(*args)
        cms = $star_collect.map do |id|
            CookMenu.find_by_id(id)
        end

        rels = []

        cms.each do |cm|
            unless cm.default_image.cook_image
                next 
            end
            path = cm.default_image.cook_image.name
            new_path = File.join("/images","shave_#{File.basename(path)}")
            contect = '无'
            if !cm.contect || cm.contect.size==0
                contect = cm.cook_images.map do |e|
                    e.ai_contect.to_s
                end.join(' ')
            else 
                contect = cm.contect
            end

            rels << {
                star: $star_collect.include?(cm.id),
                contect: contect,
                path: new_path,
                id: cm.id
            }
        end

        JSON.generate(rels)
    end
    # get "/shavefeedimages/:name" do 
    #     fn = File.join($_api_root_path,"/shave_images/shave_#{params['name']}")
    #     if(File.exist? fn)
    #         send_file fn
    #     else
    #         # send_file File.join($_api_root_path,"/shave_images/shave_idle.png")
    #         ''
    #     end
    # end

    # ## 获取vue模板
    # get "/component/:name" do 
    #     Mylog::log.info params
    #     send_file File.join($_api_root_path,"/static/vue-components/#{params['name']}"),:type => :text
    # end

    # run!
  end

#   exit
