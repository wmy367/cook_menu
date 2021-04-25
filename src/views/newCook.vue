<template>
    <div id='new_cook'>
        <van-row>
            <van-col span="24">
                <van-uploader 
                    v-model='imageList'
                    :after-read="afterRead" 
                    multiple 
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
                        :autosize="{ maxHeight: 400, minHeight: 100 }"
                    >
                    </van-field>
                </van-cell-group>
            </van-col>
            
            <van-col span="8" offset="8" style="margin-top:1rem;">
                <van-button type="primary" round size="large" block @click="create_new">提交</van-button>
            </van-col>
        </van-row>
        
    </div>
</template>

<script>
import Vue from 'vue';
import { Uploader } from 'vant';
import { Toast } from 'vant';

import upLoaderImg from "../js/upLoaderImg"
import axios from 'axios'
Vue.use(Uploader);
// Vue.use(Toast)

export default {
    name: 'newCook',
    data(){
        return {
            cook_flow: '',
            uploadDoneList: [],
            imageList: []
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
            let uploadImg = upLoaderImg(file.file)//使用上传的方法。file.file
            uploadImg.then(
                // 记录填充值
                function(data){
                    // console.log(data)
                    // console.log(data.status)
                    if(data.status){
                        _this.uploadDoneList.push(data.image_file)
                    }
                }
            ).catch(
                // 记录失败原因
                function(data){
                    console.log(data)
                }
            );
        },
        create_new(){
            let _this = this
            
            //把 uploadUrl 换成自己的 上传路径
            _this.post("/create_menu", {files: _this.uploadDoneList ,contect: _this.cook_flow }).then(res => {
                if(res ){
                    _this.$parent.active = 0;
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
</style>