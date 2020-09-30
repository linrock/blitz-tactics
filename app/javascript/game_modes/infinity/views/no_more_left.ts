import { subscribe, subscribeOnce } from '@blitz/store'

export default class NoMoreLeft {

  get el(): HTMLElement {
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
