// Tracks progress within the level and whether the next level is unlocked
//
export default class LevelStatus {

  constructor() {
    this.completed = false
    this.numPuzzles = 0
    this.puzzleCounter = 0
  }

  setNumPuzzles(numPuzzles) {
    this.numPuzzles = numPuzzles
  }

  nextPuzzle() {
    this.puzzleCounter += 1
  }

  getProgress() {
    let progress = ~~( 100 * this.puzzleCounter / this.numPuzzles )
    if (progress > 100) {
      progress = 100
    }
    return progress
  }

  resetProgress() {
    this.puzzleCounter = 0
  }

  nextLevelUnlocked() {
    return this.getProgress() === 100
  }
}
