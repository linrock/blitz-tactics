import { subscribe, subscribeOnce } from '../../../store'

export default class NoMoreLeft {

  get el() {
    return document.querySelector(`.no-more-left`)
  }

  constructor() {
    subscribe({
      'puzzles:complete': () => {
        this.el.classList.remove(`invisible`)
        setTimeout(() => {
          subscribeOnce(`difficulty:set`, () => {
            this.el.classList.add(`invisible`)
          })
        }, 1000)
      }
    })
  }
}
