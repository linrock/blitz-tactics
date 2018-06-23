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

export function speedrunCompleted(time) {
  return client.post(`/speedrun`, time).then(resp => resp.data)
}

export function fetchPuzzles(source) {
  const defaultSource = window.location.pathname + ".json"
  return client.get(source || defaultSource).then(resp => resp.data)
}
