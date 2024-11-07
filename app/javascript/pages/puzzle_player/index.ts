import PuzzlePlayer from '@blitz/components/puzzle_player'

console.log('starting puzzle player')
new PuzzlePlayer({
  shuffle: false,
  loopPuzzles: false,
  noHint: true,
  source: '/haste/puzzles',
})