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
  subscribeOnce('move:try', () => {
    createApp(PuzzleSetSidebar).mount('.puzzle-set .vue-app-mount')
    const el: HTMLDivElement = document.querySelector('.puzzle-set .vue-app-mount')
    el.style.display = 'block'
  })
}
