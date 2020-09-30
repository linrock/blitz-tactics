// instructions that fade out after you start

import { subscribeOnce } from '@blitz/store'

export default class Sidebar {

  get el(): HTMLElement {
    return document.querySelector(`.haste-sidebar`)
  }

  constructor() {
    subscribeOnce(`move:try`, () => {
      this.el.querySelector(`.make-a-move`).remove();
      (this.el.querySelector(`.timers`) as HTMLElement).style.display = ``
    })
  }
}
