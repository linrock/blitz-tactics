import _ from 'underscore'
import Backbone from 'backbone'

import d from '../../dispatcher'

// Tracks progress within the level and whether the next level is unlocked
//
export default class LevelProgress extends Backbone.Model {

  initialize() {
    this.puzzleCounter = 0
    this.n = 0
    this.unlocked = false
    this.listenForEvents()
  }

  listenForEvents() {
    this.listenTo(d, "puzzles:fetched", (puzzles) => {
      this.n = puzzles.length
    })
    this.listenTo(d, "puzzles:next", () => {
      this.puzzleCounter += 1
      if (!this.unlocked && this.nextStageUnlocked()) {
        this.unlocked = true
        d.trigger("level:complete", blitz.levelId)
      }
    })
    this.listenTo(d, "move:fail", _.bind(this.resetProgress, this))
    this.listenTo(d, "move:too_slow", _.bind(this.resetProgress, this))
  }

  nextStageUnlocked() {
    return this.checkProgress() == 100
  }

  checkProgress() {
    let progress = ~~( 100 * this.puzzleCounter / this.n )
    if (progress > 100) {
      progress = 100
    }
    d.trigger("progress:update", progress)
    return progress
  }

  resetProgress() {
    this.puzzleCounter = 0
    d.trigger("progress:update", 0)
  }
}
