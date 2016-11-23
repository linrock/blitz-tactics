{

  let uciToMove = (uci) => {
    let m = {
      from: uci.slice(0,2),
      to: uci.slice(2,4)
    }
    if (uci.length === 5) {
      m.promotion = uci[4]
    }
    return m
  }


  class PositionTrainer {

    constructor() {
      this.setDebugHelpers()
      this.listenForEvents()
      setFen(this.initialFen())
    }

    initialFen() {
      let startPosition = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
      return decodeURIComponent(window.location.hash.replace("#","")) || startPosition
    }

    setDebugHelpers() {
      window.setFen = (fen) => {
        d.trigger("fen:set", fen)
      }

      window.analyzeFen = (fen, depth) => {
        engine.analyze(fen, { depth: depth })
      }
    }

    listenForEvents() {
      let engine = new StockfishEngine({ multipv: 1 })

      d.on("fen:set", (fen) => {
        engine.analyze(fen)
      })

      d.on("move:try", (move) => {
        d.trigger("move:make", move)
        d.trigger("move:highlight", move)
      })

      d.on("analysis:done", (data) => {
        console.dir(data)
        if (data.fen.indexOf(" b ") > 0) {
          d.trigger("move:try", uciToMove(data.eval.best))
        }
      })
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
        d.trigger("analysis:done", {
          fen: fen,
          eval: state.eval
        })
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
