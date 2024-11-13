<template lang="pug">
  .new-puzzle-player
    .board-area-container
      .board-area
        .chessground-board
          .piece-promotion-modal-mount
          .chessground
          .board-modal-container.invisible(style="display: none")
        svg.new-chessboard-resizer-icon
          use(xlink:href="#resize-bottom-right")
        .new-chessboard-resizer

    .new-puzzle-player-instructions
      .whose-turn
        div(v-if="true")
          svg(style="width: 40px; height: 40px; margin-right: 12px")
            use(xlink:href="#wk")
          | White to move
        div(v-if="false")
          svg(style="width: 40px; height: 40px; margin-right: 12px")
            use(xlink:href="#bk")
          | Black to move
      .goal Solve 10 puzzles

</template>

<script lang="ts">
  import { subscribe } from '@blitz/events'
  import { trackEvent } from '@blitz/utils'
  import ChessgroundBoard from '../chessground_board'
  // import MoveStatus from '../move_status'
  // import ComboCounter from './views/combo_counter'
  // import Instructions from './views/instructions'
  // import PuzzleHint from './views/puzzle_hint'
  import DragChessboardResizer from './views/drag_chessboard_resizer'
  import PuzzleSource, { PuzzleSourceOptions } from './puzzle_source'

  import './style.sass'

  export default {
    mounted() {
      console.log('vue new puzzle player');

      new PuzzleSource({
        source: '/haste/puzzles'
      })

      const w = window.innerWidth;
      const h = window.innerHeight;
      console.log(`window size: ${w}x${h}`);
      const size = 8 * Math.round(Math.min(w, h) / 8) - 192;

      const boardAreaEl: HTMLElement = document.querySelector(".board-area");
      console.log(`board area size: ${boardAreaEl.style.width}x${boardAreaEl.style.height}`);
      boardAreaEl.style.width = `${size}px`;
      boardAreaEl.style.height = `${size}px`;

      // views
      new ChessgroundBoard
      new DragChessboardResizer

      // new MoveStatus
      // new Instructions
      // if (!options.noCounter) {
        // new ComboCounter
      // }
      // if (!options.noHint) {
      //   new PuzzleHint
      // }

      subscribe({
        'puzzle:solved': puzzle => {
          trackEvent(`puzzle solved`, window.location.pathname, puzzle.id)
        }
      })
    }
  }
</script>
