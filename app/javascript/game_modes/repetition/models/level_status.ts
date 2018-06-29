// Tracks progress within the level and whether the next level is unlocked
//
export default class LevelStatus {
  private numPuzzles = 0
  private puzzleCounter = 0
  public completed = false

  public setNumPuzzles(numPuzzles: number) {
    this.numPuzzles = numPuzzles
  }

  public nextPuzzle(): void {
    this.puzzleCounter += 1
  }

  public getProgress(): number {
    let progress = ~~( 100 * this.puzzleCounter / this.numPuzzles )
    if (progress > 100) {
      progress = 100
    }
    return progress
  }

  public resetProgress(): void {
    this.puzzleCounter = 0
  }

  public nextLevelUnlocked(): boolean {
    return this.getProgress() === 100
  }
}
