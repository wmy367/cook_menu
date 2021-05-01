<template>
    <div id="menu_show" ref="menu_show">
        <div v-if="!show_single_menu">
            <van-row class="list_menu" v-for="(item,i) in menu_list" :key="i" >
                    <van-col span="8" :offset="0">
                        <van-image
                            lazy-load
                            width="6rem"
                            height="6rem"
                            fit="fill"
                            :radius="6"
                            :src="item.path"
                            class="image_sh"
                            @click="show_contect(item.id)"
                            />
                    </van-col>
                    <van-col class="show-contect" span="15" :offset="0" @click="show_contect(item.id)">
                        {{contect_compact( item.contect)}}
                    </van-col>
                
            </van-row>
        </div>
         <div class="single_menu" v-if="show_single_menu">
             <van-nav-bar
                :right-text="(menu_obj.star ? '取消收藏' : '收藏')"
                left-text="返回"
                left-arrow
                @click-left="onClickLeft"
                @click-right="onClickRight"
                />
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
        // show_single_menu: Boolean
    },
    data(){
        return{
            show_single_menu: false,
            menu_obj: false,
            mlist_scrollTop:0
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
            // this.$parent.mlist_scrollTop = this.$parent.$refs.mlist.scrollTop
            this.mlist_scrollTop = this.$refs.menu_show.scrollTop
            // console.log(this.$refs.menu_show.scrollTop)
            // console.log(document.getElementById('menu_show').scrollTop)
            // console.log(event.target.top)
            _this.post("/singleMenu",{id: i}).then(res => {
                if(res ){
                    
                    _this.menu_obj = res
                    _this.show_single_menu = true
                    _this.$parent.active = 2
                    _this.$parent.show_single_menu = true
                }else{
                    Toast.fail('系统异常')
                }
            }).catch(err => {
                _this.show_single_menu = false
                Toast.fail('js 异常')
                //   reject(err)
                console.log(err)
            });
        },
        contect_compact(ct){
            if(ct.length > 100){
                return ct.slice(0,96)+"..."
            }else{
                return ct
            }
        },
        onClickLeft(){
            this.show_single_menu = false
            this.$parent.show_single_menu = false
            this.$parent.active = 0
            // this.$parent.$refs.mlist.scrollTop = this.$parent.mlist_scrollTop
            this.$refs.menu_show.scrollTop = this.mlist_scrollTop
        },
        onClickRight(){
            let _this = this
            if(this.menu_obj.star){
                _this.post("/star_menu",{menu_id: _this.menu_obj.id }).then(res => {
                    if(res ){
                        Toast('取消收藏成功')
                        _this.menu_obj.star = false
                    }else{
                        Toast.fail('系统异常')
                    }
                }).catch(err => {
                    Toast.fail('js 异常')
                    console.log(err)
                });
            }else{
                _this.post("/star_menu",{star: true,menu_id: _this.menu_obj.id }).then(res => {
                    if(res ){
                        Toast('收藏成功')
                        _this.menu_obj.star = true
                    }else{
                        Toast.fail('系统异常')
                    }
                }).catch(err => {
                    Toast.fail('js 异常')
                    console.log(err)
                });

            }
        }
    },
    computed:{
        
    }
}
</script>

<style>
.list_menu{
    margin: 3px 0px 2px 0px;
}
.show-contect {
    text-align: left;
    word-wrap: break-word;
    border: 0.1rem solid #b5c9a9;
    border-radius: 6px;
    padding: 5px;
}

.image_sh{
    background-color: #CCC;
}
</style>