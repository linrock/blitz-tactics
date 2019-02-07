declare var blitz: any

import { UciMove, ChessMove } from './types'

const uciToMove = (uci: UciMove): ChessMove => {
  const m: ChessMove = {
    from: uci.slice(0,2),
    to: uci.slice(2,4)
  }
  if (uci.length === 5) {
    m.promotion = uci[4]
  }
  return m
}

const moveToUci = (move: ChessMove): UciMove => {
  if (move.promotion) {
    return `${move.from}${move.to}${move.promotion}`
  } else {
    return `${move.from}${move.to}`
  }
}

const shuffle = (original: Array<any>): Array<any> => {
  const array = original.slice(0)
  let counter = array.length
  while (counter > 0) {
    let index = Math.floor(Math.random() * counter)
    counter--
    let temp = array[counter]
    array[counter] = array[index]
    array[index] = temp
  }
  return array
}

const getQueryParam = (param: string): string => {
  let query = window.location.search.substring(1)
  let vars = query.split('&')
  for (let i = 0; i < vars.length; i++) {
    let pair = vars[i].split('=')
    if (decodeURIComponent(pair[0]) === param) {
      return decodeURIComponent(pair[1])
    }
  }
}

const getConfig = (param: string): string => {
  let query = getQueryParam(param)
  if (blitz.position) {
    return blitz.position[param] || query
  }
  return query
}

const formattedTime = (milliseconds: number): string => {
  const centisecondsStr = ("" + milliseconds % 1000)[0]
  const seconds = ~~( milliseconds / 1000 )
  const secondsStr = ("0" + (seconds % 60)).slice(-2)
  const minutes = ~~( seconds / 60 )
  return `${minutes}:${secondsStr}.${centisecondsStr}`
}

const formattedTimeSeconds = (milliseconds: number): string => {
  const seconds = ~~( milliseconds / 1000 )
  const secondsStr = ("0" + (seconds % 60)).slice(-2)
  const minutes = ~~( seconds / 60 )
  return `${minutes}:${secondsStr}`
}

const trackEvent = (event, category, label): void => {
  const gtag = (<any>window).gtag
  if (gtag) {
    gtag('event', event, {
      event_category: category,
      event_label: label
    })
  } else {
    console.log(`event: ${event}, category: ${category}, label: ${label}`)
  }
}

export {
  uciToMove,
  moveToUci,
  shuffle,
  getQueryParam,
  getConfig,
  formattedTime,
  formattedTimeSeconds,
  trackEvent,
}
