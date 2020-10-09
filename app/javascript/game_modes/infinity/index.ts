import Vue from 'vue'

import Infinity from './infinity.vue'

import './style.sass'
import './responsive.sass'

export type InfinityPuzzleDifficulty = 'easy' | 'medium' | 'hard' | 'insane'

export interface InfinityPuzzleSolved {
  puzzle_id: number,
  difficulty: InfinityPuzzleDifficulty
}

export default function InfinityMode() {
  const app = new Vue({
    render: h => h(Infinity)
  }).$mount()
  document.querySelector('.infinity-mode .vue-app-mount').appendChild(app.$el)
}
