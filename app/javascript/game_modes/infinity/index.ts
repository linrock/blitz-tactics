import { infinityPuzzleSolved } from '@blitz/api/requests'
import PuzzlePlayer from '@blitz/components/puzzle_player'
import { dispatch, subscribe } from '@blitz/store'

import NoMoreLeft from './views/no_more_left'
import PuzzleStats from './views/puzzle_stats'
import SetDifficulty from './views/set_difficulty'

import './style.sass'
import './responsive.sass'

export type InfinityPuzzleDifficulty = 'easy' | 'medium' | 'hard' | 'insane'

interface InfinityModeConfig {
  difficulty?: InfinityPuzzleDifficulty
  numSolved?: number
}

export interface InfinityPuzzleSolved {
  puzzle_id: number,
  difficulty: InfinityPuzzleDifficulty
}

const apiPath = `/infinity/puzzles`
const fetchThreshold = 5 // fetch more puzzles when this # puzzles remain

export default function InfinityMode() {
  new PuzzleStats
  new SetDifficulty
  new NoMoreLeft

  const config: InfinityModeConfig = {}

  subscribe({
    'difficulty:selected': difficulty => {
      dispatch(
        `source:changed`,
        `${apiPath}?difficulty=${difficulty}`
      )
      dispatch(`difficulty:set`, difficulty)
    },

    'config:init': data => {
      config.difficulty = data.difficulty
      config.numSolved = data.num_solved
      dispatch(`difficulty:set`, config.difficulty)
      dispatch(`puzzles_solved:changed`, config.numSolved)
    },

    'puzzle:solved': puzzle => {
      const puzzleData = {
        puzzle_id: puzzle.id,
        difficulty: config.difficulty
      }
      infinityPuzzleSolved(puzzleData).then(data => {
        if (data.n) {
          dispatch(`puzzles_solved:changed`, data.n)
        } else {
          config.numSolved++
          dispatch(`puzzles_solved:changed`, config.numSolved)
        }
      })
    },

    'puzzles:status': status => {
      const { i, n, lastPuzzleId } = status
      if (i + fetchThreshold > n) {
        dispatch(
          `source:changed:add`,
          `${apiPath}?difficulty=${config.difficulty}&after_puzzle_id=${lastPuzzleId}`,
        )
      }
    }
  })

  new PuzzlePlayer({
    shuffle: false,
    loopPuzzles: false,
    source: apiPath,
  })
}
