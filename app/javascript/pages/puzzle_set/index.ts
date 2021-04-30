import { createApp } from 'vue'

import PuzzlePlayer from '@blitz/components/puzzle_player'
import { subscribeOnce } from '@blitz/events'
import PuzzleSetSidebar from './sidebar.vue'

import './style.sass'

// creates a chessboard and starts the puzzle player. after the player makes a move,
// a new sidebar is created
export default () => {
  new PuzzlePlayer({
    shuffle: false,
    loopPuzzles: false,
    noCounter: true,
    noHint: true,
    source: `${window.location.pathname}/puzzles.json`,
  })
  const vueAppSelector = '.puzzle-set .vue-app-mount'
  subscribeOnce('move:try', () => {
    createApp(PuzzleSetSidebar).mount(vueAppSelector)
    const el: HTMLDivElement = document.querySelector(vueAppSelector)
    el.style.display = 'block'
  })
}
