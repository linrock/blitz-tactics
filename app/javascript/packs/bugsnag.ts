import Bugsnag from '@bugsnag/js'

const bugsnagOptions = JSON.parse(
  document.querySelector("#bugsnag-options-json").innerHTML
)
Bugsnag.start(bugsnagOptions);
