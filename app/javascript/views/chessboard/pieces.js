import $ from 'jquery'

// For handling the DOM elements of the pieces on the board
//
export default class Pieces {

  constructor(board) {
    this.board = board
    this.$buffer = $("<div>").addClass("piece-buffer")
    this.initializeAllPieces()
  }

  initializeAllPieces() {
    ['w','b'].forEach(color => {
      'rnbqkbnrpppppppp'.split('').forEach(type => {
        this.$getPiece({ color: color, type: type })
      })
    })
  }

  reset() {
    this.board.$(".piece").appendTo(this.$buffer)
  }
  
  $getPiece(piece) {
    let className = piece.color + piece.type
    let $piece = this.$buffer.find(`.${className}`).first()
    if ($piece.length) {
      return $piece
    }
    return $(`
      <svg class="piece ${className} ${piece.color}" viewBox="0 0 45 45">
        <use xlink:href="#${className}" width="100%" height="100%"/>
      </svg>
    `)
    /*
    return $("<img>").
      attr("src", `/assets/pieces/${className}.png`).
      addClass(`piece ${className} ${piece.color}`)
    */
  }
}


