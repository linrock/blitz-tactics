import PuzzlePlayer from '@blitz/components/new_puzzle_player'
import "./style.sass"

export default () => {
  console.log('starting new puzzle player')
  const w = window.innerWidth;
  const h = window.innerHeight;

  console.log(`window size: ${w}x${h}`);
  const size = 8 * Math.round(Math.min(w, h) / 8) - 192;

  const boardAreaEl: HTMLElement = document.querySelector(".board-area");
  console.log(`board area size: ${boardAreaEl.style.width}x${boardAreaEl.style.height}`);
  boardAreaEl.style.width = `${size}px`;
  boardAreaEl.style.height = `${size}px`;

  new PuzzlePlayer({
    shuffle: false,
    loopPuzzles: false,
    noHint: true,
    source: '/haste/puzzles',
  })
}
