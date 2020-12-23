// TODO these are currently unused

export enum PuzzleEvent {
  Loaded = 'puzzle:loaded',
  Solved = 'puzzle:solved',
}

export enum PuzzlesEvent {
  Fetched = 'puzzles:fetched',
  Next = 'puzzles:next',
  Start = 'puzzles:start',
  Lap = 'puzzles:lap',
  Status = 'puzzles:status',
  Complete = 'puzzles:complete',
}
