import PuzzlePlayer from '@blitz/components/new_puzzle_player'
import "./style.sass"

export default () => {
  console.log('starting new puzzle player')
  new PuzzlePlayer({
    shuffle: false,
    loopPuzzles: false,
    noHint: true,
    source: '/haste/puzzles',
  })
}
