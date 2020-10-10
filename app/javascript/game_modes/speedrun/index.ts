import Vue from 'vue'

import Speedrun from './speedrun.vue'

import './style.sass'
import './responsive.sass'

export default function SpeedrunMode() {
  const app = new Vue({
    render: h => h(Speedrun)
  }).$mount()
  document.querySelector('.speedrun-mode .vue-app-mount').appendChild(app.$el)
}
