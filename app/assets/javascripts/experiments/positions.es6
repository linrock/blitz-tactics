{

  class PositionCreator extends Backbone.View {

    get el() {
      return ".new-position"
    }

    get events() {
      return {
        "keyup .fen-input"  : "hideError",
        "submit form"       : "_validateFEN"
      }
    }

    initialize() {
      this.$fen = this.$(".fen-input")
      this.$goal = this.$(".position-goal")
      this.$error = this.$(".error-message")
      this.persist = this.$("form").attr("method") === "POST"
    }

    showError(text) {
      this.$error.removeClass("invisible").text(text)
    }

    hideError() {
      console.log("hide the error")
      this.$error.addClass("invisible")
    }

    fen() {
      return $.trim(this.$fen.val())
    }

    _validateFEN(e) {
      let fen = this.fen()
      if (fen.length === 0) {
        this.showError("FEN can't be blank")
        e.preventDefault()
        return
      }
      if (fen.split(" ").length === 4) {
        fen = fen + " 0 1"
      }
      let check = new Chess().validate_fen(fen)
      if (!check.valid) {
        this.showError(check.error)
        e.preventDefault()
        return
      }
      if (!this.persist) {
        this.createPosition()
        e.preventDefault()
      }
    }

    createPosition() {
      let fen = this.fen()
      let goal = this.$goal.val()
      if (fen.split(" ").length === 4) {
        fen = fen + " 0 1"
      }
      window.location = `/position?goal=${goal}&fen=${fen}`
    }

  }


  Experiments.PositionCreator = PositionCreator

}
