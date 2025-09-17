import { createApp } from 'vue'

import Infinity from './infinity.vue'
import SolutionViewer from '../../pages/infinity'

import './style.sass'
import './responsive.sass'

export type InfinityPuzzleDifficulty = 'easy' | 'medium' | 'hard' | 'insane'

export interface InfinityPuzzleSolved {
  puzzle_id: number,
  difficulty: InfinityPuzzleDifficulty
}

export default function InfinityMode() {
  createApp(Infinity).mount('.infinity-mode .vue-app-mount')
  
  // Initialize solution viewer for recent puzzles
  SolutionViewer()
}
