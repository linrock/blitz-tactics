import client from './client'

export function updateLevel(levelSlug, data) {
  return client.put(`/${levelSlug}`, data).then(resp => resp.data)
}

export function infinityPuzzleSolved(puzzle) {
  return client.post(`/infinity/puzzles`, { puzzle }).then(resp => resp.data)
}

export function repetitionLevelAttempted(levelPath, elapsedTimeMs) {
  const params = {
    round: {
      elapsed_time_ms: elapsedTimeMs
    }
  }
  return client.post(`${levelPath}/attempt`, params)
}

export function repetitionLevelCompleted(levelPath) {
  return client.post(`${levelPath}/complete`).then(resp => resp.data)
}

export function speedrunCompleted(levelName, elapsedTimeMs) {
  const params = {
    speedrun: {
      level_name: levelName,
      elapsed_time_ms: elapsedTimeMs
    }
  }
  return client.post(`/speedrun`, params).then(resp => resp.data)
}

export function countdownCompleted(levelName, score) {
  const params = {
    countdown: {
      level_name: levelName,
      score,
    }
  }
  return client.post(`/countdown`, params).then(resp => resp.data)
}

export function hasteRoundCompleted(score) {
  const params = {
    haste: {
      score,
    }
  }
  return client.post(`/haste`, params).then(resp => resp.data)
}

export function fetchPuzzles(source) {
  return client.get(source).then(resp => resp.data)
}

export function toggleSound(enabled) {
  const params = {
    settings: {
      sound_enabled: enabled,
    }
  }
  return client.patch(`/settings`, params).then(resp => resp.data)
}
