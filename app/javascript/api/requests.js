import client from './client'

export function updateLevel(levelSlug, data) {
  return client.put(`/${levelSlug}`, data).then(resp => resp.data)
}

export function infinityPuzzleSolved(puzzle) {
  return client.post(`/api/infinity`, { puzzle }).then(resp => resp.data)
}

export function repetitionLevelAttempted(levelId, round) {
  return client.post(`/api/levels/${levelId}/attempt`, { round })
}

export function repetitionLevelCompleted(levelId) {
  return client.post(`/api/levels/${levelId}/complete`).then(resp => resp.data)
}

export function fetchPuzzles(source) {
  const defaultSource = window.location.pathname + ".json"
  return client.get(source || defaultSource).then(resp => resp.data)
}
