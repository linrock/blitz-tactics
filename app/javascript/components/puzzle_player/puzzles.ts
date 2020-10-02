// de-duplicates puzzles

import { Puzzle } from '@blitz/types'
import { shuffle } from '@blitz/utils'

export default class Puzzles {
  private puzzleList: Puzzle[] = []
  private puzzleIdSet: Set<number> = new Set()

  public addPuzzles(puzzles: Puzzle[]) {
    puzzles.forEach(puzzle => {
      if (!this.puzzleIdSet.has(puzzle.id)) {
        this.puzzleIdSet.add(puzzle.id)
        this.puzzleList.push(puzzle)
      }
    })
  }

  // Shuffles the list of puzzles. Makes sure the last puzzle
  // in the previous list is different from the first puzzle in the
  // newly-shuffled list.
  public shuffle() {
    let shuffled = shuffle(this.puzzleList)
    while (this.lastPuzzle().fen === shuffled[0].fen) {
      shuffled = shuffle(this.puzzleList)
    }
    this.puzzleList = shuffled
  }

  public count(): number {
    return this.puzzleList.length
  }

  public puzzleAt(index: number): Puzzle {
    return this.puzzleList[index]
  }

  public lastPuzzle(): Puzzle {
    return this.puzzleAt(this.count() - 1)
  }
}
