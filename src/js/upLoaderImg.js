import Vue from 'vue';
import { Toast } from 'vant';
import axios from 'axios'
Vue.use(Toast);

function upLoaderImg (file) {	//file为 你读取成功的回调文件信息
    //new 一个FormData格式的参数
    let params = new FormData()
    params.append('file', file)
    let config = {
        headers: { //添加请求头
              'Content-Type': 'multipart/form-data'
        }
      }
    return new Promise((resolve, reject) => {
        //把 uploadUrl 换成自己的 上传路径
        axios.post('/cook_images', params, config).then(res => {
            // console.log(res)
            if (res && res.data && res.data.status) {				//如果为真 resolve出去
                resolve(res.data)
            } else {
                //否则 Toast 提示
                Toast.fail(res.data && (res.data.msg))
                reject(res.data)
            }
        }).catch(err => {
              Toast.fail('系统异常')
              reject(err)
        });
    })
}
export default upLoaderImg
