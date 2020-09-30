import client from './client'
import { InfinityPuzzleSolved } from '../game_modes/infinity'

export function updateLevel(levelSlug: string, data) {
  return client.put(`/${levelSlug}`, data).then(resp => resp.data)
}

export function infinityPuzzleSolved(puzzle: InfinityPuzzleSolved) {
  return client.post(`/infinity/puzzles`, { puzzle }).then(resp => resp.data)
}

export function repetitionLevelAttempted(levelPath: string, elapsedTimeMs: number) {
  const params = {
    round: {
      elapsed_time_ms: elapsedTimeMs
    }
  }
  return client.post(`${levelPath}/attempt`, params)
}

export function repetitionLevelCompleted(levelPath: string) {
  return client.post(`${levelPath}/complete`).then(resp => resp.data)
}

export function speedrunCompleted(levelName: string, elapsedTimeMs: number) {
  const params = {
    speedrun: {
      level_name: levelName,
      elapsed_time_ms: elapsedTimeMs
    }
  }
  return client.post(`/speedrun`, params).then(resp => resp.data)
}

export function countdownCompleted(levelName: string, score: number) {
  const params = {
    countdown: {
      level_name: levelName,
      score,
    }
  }
  return client.post(`/countdown`, params).then(resp => resp.data)
}

export function hasteRoundCompleted(score: number) {
  const params = {
    haste: {
      score,
    }
  }
  return client.post(`/haste`, params).then(resp => resp.data)
}

export function ratedPuzzleAttempted(puzzleId: number, uciMoves, elapsedTimeMs: number) {
  const params = {
    puzzle_attempt: {
      id: puzzleId,
      uci_moves: uciMoves,
      elapsed_time_ms: elapsedTimeMs,
    }
  }
  return client.post(`/rated/attempts`, params).then(resp => resp.data)
}

export function fetchPuzzles(source: string) {
  return client.get(source).then(resp => resp.data)
}

export function toggleSound(enabled: boolean) {
  const params = {
    settings: {
      sound_enabled: enabled,
    }
  }
  return client.patch(`/settings`, params).then(resp => resp.data)
}
