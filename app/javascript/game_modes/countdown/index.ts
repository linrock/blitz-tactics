import { createApp } from 'vue'

import './style.sass'
import './responsive.sass'

import Countdown from './countdown.vue'

export default function CountdownMode() {
  createApp(Countdown).mount('.countdown-mode .vue-app-mount')
}
