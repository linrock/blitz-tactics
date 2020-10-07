// show your current high scores at the end of a haste run

import { subscribe } from '@blitz/store'

/** Player name + player high score */
type HighScore = [string, number]

export default class Complete {
  private timerEl: HTMLElement
  private highScoreEl: HTMLElement
  private highScoresEl: HTMLElement
  private highScoresListEl: HTMLElement
  private viewPuzzlesEl: HTMLLinkElement
  private puzzleIdsSeen: number[] = []

  get el(): HTMLElement {
    return document.querySelector(`.haste-mode`)
  }

  constructor() {
    this.timerEl = this.el.querySelector(`.timers`)
    this.highScoreEl = this.el.querySelector(`.haste-complete`)
    this.highScoresEl = this.el.querySelector(`.recent-high-scores`)
    this.highScoresListEl = this.highScoresEl.querySelector(`.list`)
    this.viewPuzzlesEl = this.el.querySelector(`.view-puzzles`)
    subscribe({
      'haste:complete': data => {
        this.timerEl.style.display = `none`
        this.viewPuzzlesEl.href = `/puzzles/${this.puzzleIdsSeen.join(',')}`
        this.showPersonalBest(data)
        this.showHighScores(data.high_scores)
      },
      'puzzle:loaded': data => {
        this.puzzleIdsSeen.push(data.puzzle.id)
      }
    })
  }

  private highScoreTemplate(playerName: string, score: number): string {
    return `
      <div class="high-score">
        <div class="score">${score}</div>
        <div class="player-name">${playerName}</div>
      </div>
    `
  }

  private showPersonalBest({ score, best }) {
    this.highScoreEl.style.display = ``
    this.highScoreEl.querySelector(`.your-score .score`).textContent = score
    this.highScoreEl.querySelector(`.high-score .score`).textContent = best
    this.highScoreEl.classList.remove(`invisible`)
  }

  private showHighScores(scores: HighScore[]) {
    if (!scores || scores.length < 3) {
      return
    }
    let html = ``
    scores.forEach(([playerName, score]) => {
      html += this.highScoreTemplate(playerName, score)
    })
    this.highScoresListEl.innerHTML = html
    this.highScoresEl.style.display = ``
  }
}
