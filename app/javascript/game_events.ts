// Centralized event registry for type-safe event handling
// Each enum value maps to the original string-based event name

export enum GameEvent {
  // Move events
  MOVE_TRY = 'move:try',
  MOVE_MAKE = 'move:make',
  MOVE_SUCCESS = 'move:success',
  MOVE_ALMOST = 'move:almost',
  MOVE_FAIL = 'move:fail',
  MOVE_SOUND = 'move:sound',
  MOVE_PROMOTION = 'move:promotion',

  // Puzzle events
  PUZZLE_LOADED = 'puzzle:loaded',
  PUZZLE_SOLVED = 'puzzle:solved',
  PUZZLE_HINT = 'puzzle:hint',
  PUZZLE_GET_HINT = 'puzzle:get_hint',

  // Puzzles (plural) events
  PUZZLES_START = 'puzzles:start',
  PUZZLES_NEXT = 'puzzles:next',
  PUZZLES_COMPLETE = 'puzzles:complete',
  PUZZLES_FETCHED = 'puzzles:fetched',
  PUZZLES_STATUS = 'puzzles:status',
  PUZZLES_LAP = 'puzzles:lap',

  // Game state events
  GAME_WON = 'game:won',
  GAME_LOST = 'game:lost',
  GAME_STALEMATE = 'game:stalemate',
  GAME_DRAW = 'game:draw',
  GAME_DRAWN = 'game:drawn',

  // Board events
  BOARD_FLIPPED = 'board:flipped',
  BOARD_UPDATE = 'board:update',

  // FEN/position events
  FEN_SET = 'fen:set',
  FEN_UPDATED = 'fen:updated',

  // Timer events
  TIMER_STOPPED = 'timer:stopped',
  TIMER_STOP = 'timer:stop',

  // Adventure mode specific events
  ADVENTURE_LEVEL_LOADED = 'adventure:level:loaded',
  ADVENTURE_COMBO_UPDATE = 'adventure:combo:update',
  ADVENTURE_COMBO_RESET = 'adventure:combo:reset',
  ADVENTURE_COMBO_TIMER_RESTART = 'adventure:combo:timer:restart',
  ADVENTURE_COUNTER_UPDATE = 'adventure:counter:update',
  ADVENTURE_COUNTER_RESET = 'adventure:counter:reset',

  // Quest mode events
  QUEST_LEVEL_LOADED = 'quest:level:loaded',

  // Instructions events
  INSTRUCTIONS_SET = 'instructions:set',
  INSTRUCTIONS_HIDE = 'instructions:hide',

  // Shape/hint drawing events
  SHAPE_DRAW = 'shape:draw',

  // Combo events
  COMBO_DROP = 'combo:drop',

  // Position trainer events
  POSITION_RESET = 'position:reset',

  // Config events
  CONFIG_INIT = 'config:init',
}

// Type-safe event payload definitions
export interface GameEventPayloads {
  [GameEvent.MOVE_TRY]: any; // Move object
  [GameEvent.MOVE_MAKE]: [any, { opponent?: boolean }?];
  [GameEvent.MOVE_SUCCESS]: void;
  [GameEvent.MOVE_ALMOST]: any; // Move object
  [GameEvent.MOVE_FAIL]: any; // Move object
  [GameEvent.MOVE_SOUND]: any; // Move object
  [GameEvent.MOVE_PROMOTION]: { fen: string; from: string; to: string };

  [GameEvent.PUZZLE_LOADED]: any; // Puzzle object
  [GameEvent.PUZZLE_SOLVED]: any; // Puzzle object
  [GameEvent.PUZZLE_HINT]: string;
  [GameEvent.PUZZLE_GET_HINT]: void;

  [GameEvent.PUZZLES_START]: void;
  [GameEvent.PUZZLES_NEXT]: void;
  [GameEvent.PUZZLES_COMPLETE]: void;
  [GameEvent.PUZZLES_FETCHED]: any; // Puzzles array
  [GameEvent.PUZZLES_STATUS]: any; // Status object
  [GameEvent.PUZZLES_LAP]: void;

  [GameEvent.GAME_WON]: void;
  [GameEvent.GAME_LOST]: void;
  [GameEvent.GAME_STALEMATE]: void;
  [GameEvent.GAME_DRAW]: void;
  [GameEvent.GAME_DRAWN]: void;

  [GameEvent.BOARD_FLIPPED]: boolean;
  [GameEvent.BOARD_UPDATE]: void;

  [GameEvent.FEN_SET]: [string, [string, string]?];
  [GameEvent.FEN_UPDATED]: string;

  [GameEvent.TIMER_STOPPED]: void;
  [GameEvent.TIMER_STOP]: void;

  [GameEvent.ADVENTURE_LEVEL_LOADED]: any; // Level info object
  [GameEvent.ADVENTURE_COMBO_UPDATE]: { comboCount: number; comboTarget: number };
  [GameEvent.ADVENTURE_COMBO_RESET]: { comboCount: number; comboTarget: number };
  [GameEvent.ADVENTURE_COMBO_TIMER_RESTART]: { dropTime: number };
  [GameEvent.ADVENTURE_COUNTER_UPDATE]: { puzzlesSolvedInRow: number; requiredPuzzles: number };
  [GameEvent.ADVENTURE_COUNTER_RESET]: { puzzlesSolvedInRow: number; requiredPuzzles: number };

  [GameEvent.QUEST_LEVEL_LOADED]: any; // Level info object

  [GameEvent.INSTRUCTIONS_SET]: string;
  [GameEvent.INSTRUCTIONS_HIDE]: void;

  [GameEvent.SHAPE_DRAW]: string; // Square

  [GameEvent.COMBO_DROP]: void;

  [GameEvent.POSITION_RESET]: void;

  [GameEvent.CONFIG_INIT]: any; // Config object
}

// Helper type for event handlers
export type GameEventHandler<T extends GameEvent> = 
  GameEventPayloads[T] extends void 
    ? () => void 
    : GameEventPayloads[T] extends any[]
      ? (...args: GameEventPayloads[T]) => void
      : (data: GameEventPayloads[T]) => void;

// Type-safe event map for subscribe
export type GameEventMap = {
  [K in GameEvent]?: GameEventHandler<K>;
};

