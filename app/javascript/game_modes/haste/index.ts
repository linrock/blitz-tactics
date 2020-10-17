import { createApp } from 'vue'

import Haste from './haste.vue'

import './style.sass'
import './responsive.sass'

export default function HasteMode() {
  createApp(Haste).mount('.haste-mode .vue-app-mount')
}
