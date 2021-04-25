<template>
    <div class="menu_show">
        <div v-if="!show_single_menu">
            <van-row class="list_menu" v-for="(item,i) in menu_list" :key="i" @click="show_contect(item.id)">
                <van-col span="8" :offset="1">
                    <van-image
                        lazy-load
                        width="6rem"
                        height="6rem"
                        fit="fill"
                        :radius="6"
                        :src="item.path"
                        class="image_sh"
                        />
                </van-col>
                <van-col class="show_contect" span="14" :offset="0">
                    {{item.contect}}
                </van-col>
            </van-row>
        </div>
         <div class="single_menu" v-if="show_single_menu">
            <singleMenu v-bind:menu_obj="menu_obj"/>
        </div>
    </div>
</template>

<script>
import singleMenu from "./singleMenu"
import axios from "axios"
import { Toast } from 'vant';

export default {
    name: 'menuShow',
    components:{
        singleMenu,
    },
    props:{
        menu_list: Array,
        show_single_menu: Boolean
    },
    data(){
        return{
            // show_single_menu: false,
            menu_obj: false
        }
    },
    methods:{
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
        show_contect(i){
            let _this = this 
            _this.post("/singleMenu",{id: i}).then(res => {
                if(res ){
                    
                    _this.menu_obj = res
                    _this.show_single_menu = true
                }else{
                    Toast.fail('系统异常')
                }
            }).catch(err => {
                _this.show_single_menu = false
                Toast.fail('js 异常')
                //   reject(err)
                console.log(err)
            });
        }
    }
}
</script>

<style>
.list_menu{
    margin: 2px 0px 2px 0px;
}
.show_contect {
    text-align: left;
}

.image_sh{
    background-color: #CCC;
}
</style>