import Vue from 'vue'
import App from './App.vue'
// import router from './router'
import MintUI from 'mint-ui'
import 'mint-ui/lib/style.css'
import Vant from 'vant';
import 'vant/lib/index.css';
import './plugins/axios'

// Vue.config.productionTip = false
Vue.use(MintUI)
Vue.use(Vant)
new Vue({
  // router,
  render: h => h(App)
}).$mount('#app')

// new Vue({
//   el: '#app',
//   components: { App }
// })

