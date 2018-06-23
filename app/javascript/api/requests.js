import client from './client'

export function updateLevel(levelSlug, data) {
  return client.put(`/${levelSlug}`, data).then(resp => resp.data)
}

export function infinityPuzzleSolved(puzzle) {
  return client.post(`/infinity/puzzles`, { puzzle }).then(resp => resp.data)
}

export function repetitionLevelAttempted(levelId, round) {
  return client.post(`/levels/${levelId}/attempt`, { round })
}

export function repetitionLevelCompleted(levelId) {
  return client.post(`/levels/${levelId}/complete`).then(resp => resp.data)
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
  const defaultSource = `${window.location.pathname}/puzzles.json`
  return client.get(source || defaultSource).then(resp => resp.data)
}
