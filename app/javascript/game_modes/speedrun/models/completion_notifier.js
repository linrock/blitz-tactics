// notifies the server about completed rounds and levels

import Backbone from 'backbone'

import d from '../../../dispatcher'
import {
  // speedrunCompleted,
} from '../../../api/requests'

export default class CompletionNotifier extends Backbone.Model {

  initialize() {
    this.listenTo(d, "timer:stopped", elapsedTime => {
      speedrunCompleted(elapsedTime).then(data => {
        d.trigger("speedrun:complete", data)
      })
    })
  }
}
