<template>
  <div id="app">
    <!-- <mt-header id="search" title="固定在顶部" style="5em;"></mt-header> -->
    <!-- <mt-search v-model="search_value" cancel-text="取消" placeholder="搜索" >
    </mt-search> -->
    <van-search 
        v-if="van_tabbar_dialog"
        v-model="search_value"
        :value="search_value" 
        shape="round"
        focus
        @search="onSearch"
        background="#E0E0E0"
        
        placeholder="请输入搜索关键词">

    </van-search>

    <div class="new_cc" v-if="create_new_cook">
      <newCook/>

    </div>

    <!-- <div v-if="menu_all_show">
        <div v-for="menu_list_obj in menu_list" :key="menu_list_obj.id">
            <menuShowSS v-bind:menu_list_obj="menu_list_obj"/>
        </div>
    </div> -->

    <div v-if="menu_all_show">
        <menuShow ref="mlist" v-bind:menu_list="menu_list" />
    </div>

    <van-dialog id="van-dialog" />

    <van-tabbar v-model="active" @change="onChange" v-if="van_tabbar_dialog">
      <van-tabbar-item icon="home-o">主页</van-tabbar-item>
      <van-tabbar-item icon="plus">新建</van-tabbar-item>
      <van-tabbar-item icon="star-o">收藏</van-tabbar-item>
    </van-tabbar>
  </div>
</template>
<script>
import Vue from 'vue';
import newCook from "./views/newCook"
import menuShow from "./views/menuShow"

// import { Toast, Dialog ,Search} from 'vant';
import { Toast ,Search} from 'vant';

import axios from 'axios'
import { Tabbar, TabItem } from 'mint-ui';

Vue.component(Tabbar.name, Tabbar);
Vue.component(TabItem.name, TabItem);
Vue.use(Search)

export default {
  name: 'app',
  components:{
    newCook,
    menuShow
  },
  data(){
    return {
      active: 0,
      search_value: '',
      create_new_cook: false,
      menu_all_show: true,
      search_result:[],
      screenWidth: document.body.clientWidth,     // 屏幕宽
      screeHeight: document.body.clientHeight,    // 屏幕高
      menu_list: [],

      show_single_menu: false,
      menu_obj: false,
      collect_menu_list: [],
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
    onChange(index) {
    // event.detail 的值为当前选中项的索引
    // this.setData({ active: event.detail });
    // console.log(event)
      
      if(index===0){
        this.create_new_cook = false
        this.menu_all_show = true
        // 关闭 singleMenu
        // this.$nextTick(() => {})
        // this.$ref.mlist.show_single_menu = false
        this.show_single_menu = false
        this.create_menu()
      }else if(index===1){
          this.menu_all_show = false
          this.show_single_menu = false
          this.create_new_cook = true
      }else if(index === 2){
          // this.menu_list = this.collect_menu_list
          this.create_new_cook = false
          this.menu_all_show = true
          this.show_single_menu = false
          this.get_star_menu()
      }
    },
    onSearch(){
        let _this = this
        // console.log(909090)
        _this.menu_list = []
        _this.active = 2
        _this.post("/menus",{args: _this.search_value }).then(res => {
            if(res ){
                console.log(res)
                _this.menu_list = res
                _this.menu_all_show = true
                Toast('搜索成功')
            }else{
                Toast.fail('系统异常')
            }
        }).catch(err => {
            Toast.fail('js 异常')
            //   reject(err)
            console.log(err)
        });
        

        // Dialog.confirm({
        //     title: '标题',
        //     message: '弹窗内容',
        //     })
        //     .then(() => {
        //         // on confirm
        //         _this.create_new_cook = false
        //         _this.menu_all_show = false
        //         _this.show_single_menu = false
        //     })
        //     .catch(() => {
        //         // on cancel
        //     });
    },
    create_menu(){
      this.create_new_cook = false
        let _this = this
        _this.post("/menus",{}).then(res => {
            if(res ){
                console.log(res)
                _this.menu_list = res
                _this.menu_all_show = true
                Toast('成功')
            }else{
                Toast.fail('系统异常')
            }
        }).catch(err => {
            Toast.fail('js 异常')
            //   reject(err)
            console.log(err)
        });
    },
    get_star_menu(){
        this.create_new_cook = false
        let _this = this
        _this.post("/get_star_menus",{}).then(res => {
            if(res ){
                console.log(res)
                _this.menu_list = res
                _this.menu_all_show = true
                Toast('成功')
            }else{
                Toast.fail('系统异常')
            }
        }).catch(err => {
            Toast.fail('js 异常')
            //   reject(err)
            console.log(err)
        });
    },
    show_menu_tri(id){
        console.log(id)
    }
  },
  computed:{
    van_tabbar_dialog(){
      return (!this.create_new_cook && !this.show_single_menu)
    }
  },
  watch:{
    active: {
      handler(new_v,old_v){
        if(new_v === "新建"){
          console.log(old_v)
        }
      }
    }
  },
  created(){
      this.create_menu()
  } 
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}

/* .van-col {
    margin-bottom: 10px;
    color: #fff;
    font-size: 13px;
    line-height: 30px;
    text-align: center;
    background-clip: content-box;
    background-color: #39a9ed;
} */

#xnavbar {
  position:fixed;
  bottom:0px;
  transform: translateZ(0);
  -webkit-transform: translateZ(0);
}

.new_cc {
  margin-top: 3em;
}
.mint-tabbar {
  height: 4em;
}

.mint-header {
  height: 6em;
}

#search{
  height: 5em;
}

#nav {
  padding: 30px;
}

#nav a {
  font-weight: bold;
  color: #2c3e50;
}

#nav a.router-link-exact-active {
  color: #42b983;
}
</style>
