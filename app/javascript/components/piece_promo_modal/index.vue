<template>
<div class="piece-promotion-modal-container"
     :style="{ display: sDisplay, zIndex: sZIndex }">
  <div class="piece-promotion-modal">
    <div class="prompt">
      Choose your destiny
    </div>
    <div class="pieces">
      <div v-for="piece in ['q', 'r', 'n', 'b']" :key="piece">
        <a class="piece" @click="selectPiece(piece)">
          <svg viewBox="0 0 45 45">
            <use :xlink:href="colorPieceId(piece)" width="100%" height="100%"/>
          </svg>
        </a>
      </div>
    </div>
  </div>
  <div class="background" @click="cancelMove"></div>
</div>

</template>

<script lang="ts">
  import Mousetrap from 'mousetrap'
  import { Chess, ShortMove, Square } from 'chess.js'

  import { dispatch, subscribe } from '@blitz/events'
  import { FEN } from '@blitz/types'

  import './style.sass'

  const cjs = new Chess

  export default {
    data() {
      return {
        fen: false,
        moveIntent: false,
        lastMove: false,
        sDisplay: 'none',
        sZIndex: '0',
      }
    },

    mounted() {
      subscribe({
        'move:promotion': data => {
          this.fen = data.fen
          this.moveIntent = data.move as ShortMove
          this.lastMove = data.lastMove
          this.color = this.fen.includes(' w ') ? 'w' : 'b'
          this.show()
        }
      })
    },

    methods: {
      show() {
        this.sDisplay = 'block'
        this.sZIndex = '1000'
        Mousetrap.bind('esc', () => this.cancelMove())
      },

      hide() {
        this.sDisplay = 'none'
        this.sZIndex = '0'
        Mousetrap.unbind('esc')
      },

      cancelMove() {
        this.hide()
        dispatch('fen:set', this.fen, this.lastMove)
      },

      selectPiece(chosenPiece: string) {
        const move: ShortMove = Object.assign({}, this.moveIntent, {
          promotion: chosenPiece
        })
        cjs.load(this.fen)
        const m = cjs.move(move)
        if (m) {
          dispatch('move:try', m)
        }
        this.hide()
      },

      colorPieceId(piece: string) {
        return `#${this.color}${piece}`
      },
    }
  }
</script>
