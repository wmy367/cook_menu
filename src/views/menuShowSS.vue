<template>
    <div class="menu_show_ss">
         <van-row >
             <van-col span="8" :offset="1">
                 <van-image
                    lazy-load
                    width="6rem"
                    height="6rem"
                    fit="fill"
                    :radius="6"
                    :src="menu_list_obj.path"
                    />
             </van-col>
             <van-col class="show_contect" span="14" :offset="0">
                 {{menu_list_obj.contect}}
             </van-col>
         </van-row>
    </div>
</template>

<script>
export default {
    name: 'menuShowSS',
    props:{
        menu_list_obj: Object
    },
}
</script>

<style>
.list_menu{
    margin: 2px 0px 2px 0px;
}
.show_contect {
    text-align: left;
}
</style>