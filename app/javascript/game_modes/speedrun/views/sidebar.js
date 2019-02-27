// instructions that fade out after you start

import { subscribeOnce } from '../../../store'

export default class Sidebar {

  get el() {
    return document.querySelector(`.speedrun-sidebar`)
  }

  constructor() {
    subscribeOnce({
      'move:try': () => {
        this.el.querySelector(`.make-a-move`).remove()
        this.el.querySelector(`.timers`).style = ``
      }
    })
  }
}
