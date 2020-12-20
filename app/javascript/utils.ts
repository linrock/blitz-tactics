import { UciMove, BlitzConfig } from './types'
import { ShortMove, Square } from 'chess.js'

declare var blitz: BlitzConfig

export const uciToMove = (uci: UciMove): ShortMove => {
  const m: ShortMove = {
    from: (uci.slice(0,2) as Square),
    to: (uci.slice(2,4) as Square)
  }
  if (uci.length === 5) {
    m.promotion = uci[4] as 'n' | 'b' | 'r' | 'q' | 'k'
  }
  return m
}

export const moveToUci = (move: ShortMove): UciMove => {
  if (move.promotion) {
    return `${move.from}${move.to}${move.promotion}`
  } else {
    return `${move.from}${move.to}`
  }
}

export const shuffle = (originalArray: any[]): any[] => {
  const shuffledArray = originalArray.slice(0)
  let counter = shuffledArray.length
  while (counter > 0) {
    let index = Math.floor(Math.random() * counter)
    counter--
    let temp = shuffledArray[counter]
    shuffledArray[counter] = shuffledArray[index]
    shuffledArray[index] = temp
  }
  return shuffledArray
}

export const getQueryParam = (param: string): string => {
  let query = window.location.search.substring(1)
  let vars = query.split('&')
  for (let i = 0; i < vars.length; i++) {
    let pair = vars[i].split('=')
    if (decodeURIComponent(pair[0]) === param) {
      return decodeURIComponent(pair[1])
    }
  }
}

// blitz config options can be overriden using query params
export const getConfig = (param: (keyof BlitzConfig) | string): string => {
  const query = getQueryParam(param as string)
  if (blitz.position) {
    // Positions can be set from query params
    return blitz.position[param] || query
  }
  return query
}

// Outputs minutes and seconds and centiseconds
// Example: 7,500ms  = 7.5s     = 0:07.5
// Example: 80,000ms = 1min 20s = 1:20.0
export const formattedTime = (milliseconds: number): string => {
  const centisecondsStr = ("" + milliseconds % 1000)[0]
  const seconds = ~~( milliseconds / 1000 )
  const secondsStr = ("0" + (seconds % 60)).slice(-2)
  const minutes = ~~( seconds / 60 )
  return `${minutes}:${secondsStr}.${centisecondsStr}`
}

// Outputs minutes and seconds
// Example: 7,500ms  = 7.5s     = 0:07
export const formattedTimeSeconds = (milliseconds: number): string => {
  const seconds = ~~( milliseconds / 1000 )
  const secondsStr = ("0" + (seconds % 60)).slice(-2)
  const minutes = ~~( seconds / 60 )
  return `${minutes}:${secondsStr}`
}

export const trackEvent = (event: string, category: string, label: string): void => {
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
