<template>
    <div id='new_cook'>
        <van-row>
            <van-col span="24">
                <van-uploader 
                    v-model='imageList'
                    :after-read="afterRead" 
                    multiple 
                    accept="image"
                    sizeType="compressed"
                    preview-size="99px"/>
            </van-col>
            <van-col span="24" offset="0">
                <van-cell-group>
                    <van-field
                        v-model="cook_flow"
                        type="textarea"
                        placeholder="请输入菜谱"
                        auto-focus
                        :border="true"
                        :autosize="{ maxHeight: 300, minHeight: 100 }"
                    >
                    </van-field>
                </van-cell-group>
            </van-col>
            
            <van-col span="9" offset="2" style="margin-top:1rem;">
                <van-button type="default" round  block @click="cancle_create_new">取消</van-button>
            </van-col>
            <van-col span="9" offset="2" style="margin-top:1rem;">
                <van-button type="primary" round  block @click="create_new">提交</van-button>
            </van-col>
        </van-row>
        <!-- <van-tabbar v-model="active" >
            <van-tabbar-item >
                <van-button  round size="large" block @click="cancle_create_new">取消</van-button>
            </van-tabbar-item>
            <van-tabbar-item >
                <van-button type="primary" round size="large" block @click="create_new">提交</van-button>
            </van-tabbar-item>
        </van-tabbar> -->
        <van-overlay :show="loading" >
            <div class="wrapper">
                <div class="block" catch:tap="noop" >
                    <van-loading size="100px">上传中...</van-loading>
                </div>
            </div>
        </van-overlay>
    </div>
</template>

<script>
import Vue from 'vue';
import { Uploader,Dialog} from 'vant';
import { Toast } from 'vant';

import upLoaderImg from "../js/upLoaderImg"
import axios from 'axios'
Vue.use(Uploader);
// Vue.use(Toast)

export default {
    name: 'newCook',
    data(){
        return {
            active: 3,
            cook_flow: '',
            uploadDoneList: [],
            imageList: [],
            loading: false
        }
    },
    methods: {
        post(url,args){
            var params = new URLSearchParams();
            
            for(let key in args){
                params.append(key,args[key]);
            }
            return new Promise(function(resolve,reject){

                //把 uploadUrl 换成自己的 上传路径
                axios.post(url, params).then(res => {
                    // 没有登陆时
                    console.log(res)
                    if(res && res.data){
                        resolve(res.data)
                    }else{
                        Toast.fail('返回错误')
                    }
                }).catch(err => {
                    Toast.fail('系统异常')
                    reject(err)
                });
            
            })
        },
        afterRead(file){
            // console.log(file)
            let _this = this
            this.loading = true
            let uploadImg = upLoaderImg(file.file)//使用上传的方法。file.file
            uploadImg.then(
                // 记录填充值
                function(data){
                    // console.log(data)
                    // console.log(data.status)
                    _this.loading = false
                    if(data.status){
                        _this.uploadDoneList.push(data.image_file)
                        _this.loading = false
                        Dialog.alert({
                            message: "如果不输入内容，则默认采用自动识别出来的文字！",
                            })
                            .then(() => {
                                // on confirm
                            })
                    }
                }
            ).catch(
                // 记录失败原因
                function(data){
                    // console.log(data)
                    Dialog.confirm({
                        title: '上传失败',
                        message: data.image_file,
                        })
                        .then(() => {
                            // on confirm
                        })
                        .catch(() => {
                            // on cancel
                        });
                }
            );
        },
        create_new(){
            let _this = this
            if(_this.cook_flow.length > 30000){
                Toast.fail('没有内容')
            }else if( _this.uploadDoneList.length==0 ){
                Toast.fail('没有图片')
            }else{
                //把 uploadUrl 换成自己的 上传路径
                _this.post("/create_menu", {files: _this.uploadDoneList ,contect: _this.cook_flow }).then(res => {
                    if(res ){
                        // console.log(_this.uploadDoneList)
                        _this.$parent.active = 2;
                        _this.$parent.create_new_cook = false
                        
                        _this.active = 3
                        _this.$parent.menu_list.unshift(res)
                        _this.$parent.menu_all_show = true
                        Toast('成功')
                    }else{
                        Toast.fail('系统异常')
                    }
                }).catch(err => {
                    Toast.fail('js 异常')
                    //   reject(err)
                    console.log(err)
                });
            }
        },
        cancle_create_new(){
            this.$parent.create_new_cook = false
            this.$parent.menu_all_show = true
            this.active = 3
            this.$parent.active = 0
        },
        onChange(index){
            if(index===0){
                this.$parent.create_new_cook = false
                this.active = 3
            }else if(index===1){
                this.create_new()
            }
        },
        noop(){

        }
    },
    computed:{
        textaere_heigt(){
            let text_len = this.cook_flow.length;
            if(text_len < 40){
                return '6rem'
            }else{
                let new_h = (text_len-40)/40*1.28 + 6;
                return new_h.toString()+"rem"
            }
        }
    }
}
</script>

<style >
#new_cook {
    max-height: 30%;
}

.wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
}

.block {
  width: 120px;
  height: 120px;
  background-color: #fff;
}
</style>