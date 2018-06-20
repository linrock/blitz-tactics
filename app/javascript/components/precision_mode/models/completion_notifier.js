// notifies the server about completed rounds and levels

import $ from 'jquery'
import Backbone from 'backbone'

import api from '../../../api'
import d from '../../../dispatcher'

export default class CompletionNotifier extends Backbone.Model {

  initialize() {
    this.listenToEvents()
  }

  listenToEvents() {
    this.listenTo(d, "round:complete", this.roundComplete)
    this.listenTo(d, "level:complete", this.levelComplete)
  }

  roundComplete(levelId, payload) {
    if (!levelId) {
      return
    }
    api.post(`/api/levels/${levelId}/attempt`, { round: payload })
  }

  levelComplete(levelId) {
    if (!levelId) {
      return
    }
    api.post(`/api/levels/${levelId}/complete`)
      .then(response => response.data)
      .then(() => d.trigger("level:unlocked", data.next.href))
  }
}
