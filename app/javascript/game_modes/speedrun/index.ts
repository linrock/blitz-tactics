import { createApp } from 'vue'

import Speedrun from './speedrun.vue'

import './style.sass'
import './responsive.sass'

export default function SpeedrunMode() {
  const app = createApp(Speedrun)
  app.mount('.speedrun-mode .vue-app-mount')
}
