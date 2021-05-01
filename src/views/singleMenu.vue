<template>
    <div id='single_cook'>
        <van-row>
            <van-col span="24" offset="0" class="demo-col">
                <van-grid :gutter="2" :column-num="menu_obj.images.length">
                    <van-grid-item
                        v-for="obj in menu_obj.images"
                        :key="'sv_'+obj.id"
                        style="backgroud-color:#bbb"
                    >
                        <van-image :src="obj.sv_path" @click="previewImages(obj.path)" />
                    </van-grid-item>
                </van-grid>
            </van-col>
        </van-row>
        <van-row style="margin-top:5px;">
            <van-col span="22" offset="1" class="contect-show">
                {{menu_obj.contect}}
            </van-col>
        </van-row>
        <van-row>
            <van-col span="5" offset="6" style="margin-top:1rem;">
                <van-button type="warning" round  block >修改</van-button>
            </van-col>
            <van-col span="5" offset="6" style="margin-top:1rem;">
                <van-button type="danger" round  block @click="delMenu">删除</van-button>
            </van-col>
        </van-row>
        
        
    </div>
</template>

<script>
import Vue from 'vue';
import { Toast,Dialog } from 'vant';
import { ImagePreview } from 'vant';
import axios from 'axios'

Vue.use(Toast)
Vue.use(ImagePreview)

export default {
    name: 'singleMenu',
    props:{
        menu_obj: Object
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
        previewImages(obj_img_path){
            let showImagesUrl = [];   
            showImagesUrl.push(obj_img_path)
        
            ImagePreview(
                showImagesUrl
            );
        },
        delMenu(){
            let _this = this
            Dialog.confirm({
                message: '确定要删除吗？',
                })
                .then(() => {
                    _this.post("/del_menu", {menu_id: _this.menu_obj.id}).then(res => {
                        if(res ){
                            // console.log(_this.uploadDoneList)
                            _this.$parent.show_single_menu = false
                            _this.$parent.$parent.show_single_menu = false
                            _this.$parent.$parent.active = 0
                            _this.$parent.$parent.menu_list.splice( _this.$parent.$parent.menu_list.findIndex(item => item.id === _this.menu_obj.id ), 1);

                            Toast('删除成功')
                        }else{
                            Toast.fail('系统异常')
                        }
                    }).catch(err => {
                        Toast.fail('js 异常')
                        //   reject(err)
                        console.log(err)
                    });

                })
                .catch(() => {
                    // on cancel
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
.contect-show {
    border: 0.2rem solid #bdb9b5;
    padding: 4px;
    border-radius: 4px;
    word-wrap: break-word;
}
</style>