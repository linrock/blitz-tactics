import Bugsnag from '@bugsnag/js'

const apiKey = document.querySelector("#bugsnag-api-key").innerHTML
Bugsnag.start({ apiKey });
