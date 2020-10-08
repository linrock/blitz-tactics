import Vue from 'vue'

import './style.sass'
import './responsive.sass'

import CountdownTest from './index2.vue'

export default function CountdownMode() {
  const app = new Vue({
    render: h => h(CountdownTest)
  }).$mount()
  document.querySelector('.countdown-mode .container').appendChild(app.$el)
  console.log(app)
}
