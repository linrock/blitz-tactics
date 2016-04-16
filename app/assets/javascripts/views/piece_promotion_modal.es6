{

  // When you make a pawn move that requires pawn promotion,
  // this is what shows up
  //
  class PiecePromotionModal extends Backbone.View {

    get el() {
      return ".piece-promotion-modal"
    }

    get events() {
      return {
        "click .piece" : "_selectPiece"
      }
    }

    initialize() {
      this.moveIntent = false
      this.listenToEvents()
    }

    show() {
      this.$el.show()
      Mousetrap.bind("esc", _.bind(this.hide, this))
    }

    hide() {
      this.$el.hide()
      Mousetrap.unbind("esc")
    }

    listenToEvents() {
      this.listenTo(d, "move:promotion", (data) => {
        this.fen = data.fen
        this.moveIntent = data.move
        this.show()
      })
    }

    _selectPiece(e) {
      let chosenPiece = $(e.currentTarget).data("piece")
      let move = _.extend({}, this.moveIntent, { promotion: chosenPiece })
      let c = new Chess(this.fen)
      let m = c.move(move)
      if (m) {
        d.trigger("move:try", m)
      }
      this.hide()
    }

  }


  Views.PiecePromotionModal = PiecePromotionModal

}
