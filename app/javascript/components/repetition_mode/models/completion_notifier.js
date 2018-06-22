// notifies the server about completed rounds and levels

import $ from 'jquery'
import Backbone from 'backbone'

import d from '../../../dispatcher'
import {
  repetitionLevelAttempted,
  repetitionLevelCompleted
} from '../../../api/requests'

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
    repetitionLevelAttempted(levelId, payload)
  }

  levelComplete(levelId) {
    if (!levelId) {
      return
    }
    repetitionLevelCompleted(levelId)
      .then(data => d.trigger("level:unlocked", data.next.href))
  }
}
