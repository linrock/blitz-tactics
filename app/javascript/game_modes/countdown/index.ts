import Vue from 'vue'

import './style.sass'
import './responsive.sass'

import Countdown from './countdown.vue'

export default function CountdownMode() {
  const app = new Vue({
    render: h => h(Countdown)
  }).$mount()
  document.querySelector('.countdown-mode .container').appendChild(app.$el)
  console.log(app)
}
