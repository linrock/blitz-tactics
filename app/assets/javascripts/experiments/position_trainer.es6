{

  class PositionTrainer {

    constructor() {
      d.trigger("fen:set", "8/8/8/p7/6p1/2N4k/5p1P/6K1 w - -")

      let engine = new StockfishEngine({ multipv: 1 })
      engine.analyze('8/8/8/p7/6p1/2N4k/5p1P/6K1 w - -')

      window.setFen = (fen) => {
        d.trigger("fen:set", fen)
      }

      window.analyzeFen = (fen, depth) => {
        engine.analyze(fen, { depth: depth })
      }
    }

  }


  class StockfishEngine {

    constructor(options = {}) {
      this.multipv = options.multipv || 1
      this.stockfish = new Worker('/assets/stockfish.js')
      this.initStockfish()
    }

    initStockfish() {
      if (this.multipv > 1) {
        this.stockfish.postMessage('setoption name MultiPV value ' + this.multipv)
      }
      this.stockfish.postMessage('uci')
      this.initLogger()
    }

    initLogger() {
      this.stockfish.addEventListener('message', (e) => {
        console.log(e.data)
      })
    }

    analyze(fen, options = {}) {
      let targetDepth = options.depth || 10
      this.stockfish.postMessage('position fen ' + fen)
      this.emitEvaluationWhenDone(fen, targetDepth)
      this.stockfish.postMessage('go depth ' + targetDepth)
    }

    emitEvaluationWhenDone(fen, depth) {
      let start = new Date()
      let targetDepth = depth
      let targetMultiPv = this.multipv

      let done = (state) => {
        console.log("time elapsed: " + (Date.now() - start))
        console.dir(state)
        this.stockfish.removeEventListener('message', processOutput)
      }

      let state

      let processOutput = (e) => {
        if (e.data.indexOf('bestmove ') === 0) {
          return
        }

        var matches = e.data.match(/depth (\d+) .*multipv (\d+) .*score (cp|mate) ([-\d]+) .*nps (\d+) .*pv (.+)/)
        if (!matches) {
          return
        }

        var depth = parseInt(matches[1])
        if (depth < targetDepth) {
          return
        }

        var multiPv = parseInt(matches[2])
        var cp, mate

        if (matches[3] === 'cp') {
          cp = parseFloat(matches[4])
        } else {
          mate = parseFloat(matches[4])
        }

        if (fen.indexOf('w') === -1) {
          if (matches[3] === 'cp') cp = -cp
          else mate = -mate
        }

        if (multiPv === 1) {
          state = {
            eval: {
              depth: depth,
              nps: parseInt(matches[5]),
              best: matches[6].split(' ')[0],
              cp: cp,
              mate: mate,
              pvs: []
            }
          }
        } else if (!state || depth < state.eval.depth) return // multipv progress

        state.eval.pvs[multiPv - 1] = {
          cp: cp,
          mate: mate,
          pv: matches[6],
          best: matches[6].split(' ')[0]
        }

        if (multiPv === targetMultiPv && state.eval.depth === targetDepth) {
          done(state)
        }
      }

      this.stockfish.addEventListener('message', processOutput)
    }

  }


  Experiments.PositionTrainer = PositionTrainer

}
