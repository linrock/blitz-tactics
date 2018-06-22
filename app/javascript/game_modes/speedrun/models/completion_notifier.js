// notifies the server about completed rounds and levels

import $ from 'jquery'
import Backbone from 'backbone'

import d from '../../../dispatcher'
import {
  // speedrunCompleted,
} from '../../../api/requests'

export default class CompletionNotifier extends Backbone.Model {

  initialize() {
    this.listenTo(d, "speedrun:complete", () => {
      speedrunCompleted().then(() => d.trigger("final:show"))
    })
  }
}
