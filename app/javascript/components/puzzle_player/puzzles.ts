// de-duplicates puzzles

import { shuffle } from '../../utils'
import { Puzzle } from '../../types'

export default class Puzzles {
  private puzzleList: Array<Puzzle> = []
  private puzzleSet: Set<number> = new Set()

  addPuzzles(puzzles: Array<Puzzle>) {
    puzzles.forEach(puzzle => {
      if (!this.puzzleSet.has(puzzle.id)) {
        this.puzzleSet.add(puzzle.id)
        this.puzzleList.push(puzzle)
      }
    })
  }

  shuffle() {
    let shuffled = shuffle(this.puzzleList)
    while (this.lastPuzzle().fen === shuffled[0].fen) {
      shuffled = shuffle(this.puzzleList)
    }
    this.puzzleList = shuffled
  }

  count(): number {
    return this.puzzleList.length
  }

  puzzleAt(index: number): Puzzle {
    return this.puzzleList[index]
  }

  lastPuzzle(): Puzzle {
    return this.puzzleAt(this.count() - 1)
  }
}
