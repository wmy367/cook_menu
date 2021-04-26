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

        
    </div>
</template>

<script>
import Vue from 'vue';
import { Toast } from 'vant';
import { ImagePreview } from 'vant';

Vue.use(Toast)
Vue.use(ImagePreview)

export default {
    name: 'singleMenu',
    props:{
        menu_obj: Object
    },
    methods: {
        previewImages(obj_img_path){
            let showImagesUrl = [];   
            showImagesUrl.push(obj_img_path)
        
            ImagePreview(
                showImagesUrl
            );
        },
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