import client from './client'
import { InfinityPuzzleSolved } from '../game_modes/infinity'
import { Puzzle } from '../types'

export async function infinityPuzzleSolved(puzzle: InfinityPuzzleSolved) {
  return client.post(`/infinity/puzzles`, { puzzle }).then(resp => resp.data)
}

export async function repetitionLevelAttempted(levelPath: string, elapsedTimeMs: number) {
  const params = {
    round: {
      elapsed_time_ms: elapsedTimeMs
    }
  }
  return client.post(`${levelPath}/attempt`, params)
}

export async function repetitionLevelCompleted(levelPath: string) {
  return client.post(`${levelPath}/complete`).then(resp => resp.data)
}

export async function speedrunCompleted(levelName: string, elapsedTimeMs: number) {
  const params = {
    speedrun: {
      level_name: levelName,
      elapsed_time_ms: elapsedTimeMs
    }
  }
  return client.post(`/speedrun`, params).then(resp => resp.data)
}

export async function countdownCompleted(levelName: string, score: number) {
  const params = {
    countdown: {
      level_name: levelName,
      score,
    }
  }
  return client.post(`/countdown`, params).then(resp => resp.data)
}

export async function hasteRoundCompleted(score: number) {
  const params = {
    haste: {
      score,
    }
  }
  return client.post(`/haste`, params).then(resp => resp.data)
}

export async function threeRoundCompleted(score: number) {
  const params = {
    three: {
      score,
    }
  }
  return client.post(`/three`, params).then(resp => resp.data)
}

export async function ratedPuzzleAttempted(puzzleId: number, uciMoves: any[], elapsedTimeMs: number) {
  const params = {
    puzzle_attempt: {
      id: puzzleId,
      uci_moves: uciMoves,
      elapsed_time_ms: elapsedTimeMs,
    }
  }
  return client.post(`/rated/attempts`, params).then(resp => resp.data)
}

export async function fetchPuzzles(source: string): Promise<{ puzzles: Puzzle[] }> {
  return client.get(source).then(resp => resp.data)
}

export async function toggleSound(enabled: boolean) {
  const params = {
    settings: {
      sound_enabled: enabled,
    }
  }
  return client.patch(`/settings`, params).then(resp => resp.data)
}
