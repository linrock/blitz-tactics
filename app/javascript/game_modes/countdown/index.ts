import { createApp } from 'vue'

import './style.sass'
import './responsive.sass'

import Countdown from './countdown.vue'

export default function CountdownMode() {
  const app = createApp(Countdown)
  app.mount('.countdown-mode .container')
}
