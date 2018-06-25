import client from './client'

export function updateLevel(levelSlug, data) {
  return client.put(`/${levelSlug}`, data).then(resp => resp.data)
}

export function infinityPuzzleSolved(puzzle) {
  return client.post(`/infinity/puzzles`, { puzzle }).then(resp => resp.data)
}

export function repetitionLevelAttempted(levelPath, round) {
  return client.post(`${levelPath}/attempt`, { round })
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

export function fetchPuzzles(source) {
  return client.get(source).then(resp => resp.data)
}
