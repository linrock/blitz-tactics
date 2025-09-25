import { createApp, Component } from 'vue'

import InfinityMode from './game_modes/infinity'
import RepetitionMode from './game_modes/repetition'
import SpeedrunMode from './game_modes/speedrun/index.vue'
import CountdownMode from './game_modes/countdown/index.vue'
import HasteMode from './game_modes/haste/index.vue'
import MateInOneMode from './game_modes/mate_in_one/index.vue'
import ThreeMode from './game_modes/three/index.vue'
import RookEndgamesMode from './game_modes/rook-endgames/index.vue'
import OpeningsMode from './game_modes/openings/index.vue'
import RatedMode from './game_modes/rated'

import CustomizeBoard from './pages/customize_board'
import PositionTrainer from './pages/position_trainer/index.vue'
import PuzzleSet from './pages/puzzle_set'
import PuzzleList from './pages/puzzle_list'
import PuzzlePage from './pages/puzzle_page'
import UserProfile from './pages/user_profile'

import NewPuzzlePlayer from './components/new_puzzle_player/index.vue'
import PuzzlePlayer from './components/puzzle_player'
import ChessgroundBoard from './components/chessground_board'
import ChessboardResizer from './components/puzzle_player/views/chessboard_resizer'
import { dispatch, subscribe } from '@blitz/events'
import { uciToMove } from '@blitz/utils'
import QuestMode from './game_modes/quest/index.vue'
import AdventureMode from './game_modes/adventure/index.vue'

interface RouteMap {
  [routeKey: string]: () => void
}

const mountVue = (component: Component, selector: string) => {
  createApp(component).mount(selector)
}

const routes: RouteMap = {
  // game modes
  "game_modes/speedrun#index": () => mountVue(SpeedrunMode, '.speedrun-mode .vue-app-mount'),
  "game_modes/countdown#index": () => mountVue(CountdownMode, '.countdown-mode .vue-app-mount'),
  "game_modes/haste#index": () => mountVue(HasteMode, '.haste-mode .vue-app-mount'),
  "game_modes/mate_in_one#index": () => mountVue(MateInOneMode, '.mate-in-one-mode .vue-app-mount'),
  "game_modes/three#index": () => mountVue(ThreeMode, '.three-mode .vue-app-mount'),
  "game_modes/rook_endgames#index": () => mountVue(RookEndgamesMode, '.rook-endgames-mode .vue-app-mount'),
  "game_modes/openings#index": () => mountVue(OpeningsMode, '.openings-mode .vue-app-mount'),
  "game_modes/infinity#index": () => InfinityMode(),
  "game_modes/repetition#index": () => RepetitionMode(),
  "game_modes/rated#index": () => RatedMode(),

  // individual puzzle pages
  "puzzles#show": () => PuzzlePage(),

  // lists of puzzles (ex. after finishing a game)
  "puzzles#index": () => PuzzleList(),

  // puzzle sets
  "puzzle_sets#show": () => {
    // TODO wait for a move before mounting the vue app
    // mountVue(PuzzleSet, '.puzzle-set .vue-app-mount')
    PuzzleSet()
  },

  // position trainers
  "pages#position": () => mountVue(PositionTrainer, '.vue-app-mount'),
  "pages#defined_position": () => {
    // Initialize position trainer with resizable board
    const position = (window as any).blitz?.position
    
    if (!position) {
      console.error('No position data found for defined_position')
      return
    }
    
    console.log('Initializing defined_position with:', position)
    
    // Ensure FEN has proper format (add move counters if missing)
    let fen = position.fen
    if (fen && fen.split(' ').length === 4) {
      fen = `${fen} 0 1`
    }
    console.log('Using FEN:', fen)
    
    // Initialize chessboard with proper orientation and move handling
    const orientation = position.fen?.includes(' w ') ? 'black' : 'white'
    console.log('Creating ChessgroundBoard with orientation:', orientation)
    
    // Import StockfishEngine for opponent moves
    import('@blitz/workers/stockfish_engine').then(({ default: StockfishEngine }) => {
      const depth = parseInt(position.depth, 10) || 15
      const engine = new StockfishEngine
      let initialMoveMade = false
      let firstMoveMade = false
      
      // Wait for DOM to be ready before creating board
      const initializeBoard = () => {
        const chessgroundEl = document.querySelector('.chessground')
        if (!chessgroundEl) {
          console.error('Chessground element not found')
          return
        }
        
        const board = new ChessgroundBoard({
          fen: fen,
          orientation: orientation as any,
          intentOnly: false  // Allow free play
        })
        
        console.log('ChessgroundBoard created:', board)
        
        // Initialize resizer
        new ChessboardResizer()
        
        // Set up move handling for free play
        subscribe({
          'move:try': (move: any) => {
            console.log('Received move:try', move)
            
            // In checkmate practice, allow all legal moves
            if (move && (move.san || (move.from && move.to))) {
              console.log('Accepting move:', move.san || `${move.from}-${move.to}`)
              // Use move:make without opponent flag so it gets highlighted as a player move
              dispatch('move:make', move)
              
              // Fade out goal message and "White to move" after first move
              if (!firstMoveMade) {
                firstMoveMade = true
                setTimeout(() => {
                  if (goalMessageEl) {
                    goalMessageEl.classList.add('faded')
                  }
                  if (instructionsAreaEl) {
                    instructionsAreaEl.classList.add('faded')
                  }
                }, 100)
              }
            } else {
              console.log('Invalid move attempted:', move)
            }
          },
          'position:reset': () => {
            console.log('Resetting position to:', fen)
            dispatch('fen:set', fen)
            
            // Show instructions and goal message again when position is reset
            if (instructionsAreaEl) {
              instructionsAreaEl.classList.remove('faded')
            }
            if (goalMessageEl) {
              goalMessageEl.classList.remove('faded')
            }
            firstMoveMade = false
            
            // Update turn indicator for reset position
            updateTurnIndicator(fen)
          },
          'fen:updated': (currentFen: string) => {
            // Update turn indicator (always shows "White to move")
            updateTurnIndicator(currentFen)
            
            // Analyze position and make computer move if it's the computer's turn
            const analysisOptions = { depth, multipv: 1 }
            engine.analyze(currentFen, analysisOptions).then(output => {
              const { fen: analyzedFen, state } = output
              if (!state) {
                console.warn(`missing state in engine output: ${JSON.stringify(output)}`)
                return
              }
              
              // Check if this is still the current position
              if (analyzedFen !== board.getFen()) {
                return
              }
              
              // Check if it's the computer's turn
              const isComputersTurn = analyzedFen.includes(` ${orientation === 'black' ? 'w' : 'b'} `)
              if (isComputersTurn) {
                const computerMove = state.evaluation.best
                const moveObj = uciToMove(computerMove)
                
                // Make the move on the board
                const moveResult = board.cjs.move(moveObj)
                if (moveResult) {
                  // Update the board display with lastMove highlighting
                  const lastMove = [moveObj.from, moveObj.to] as [string, string]
                  dispatch('fen:set', board.cjs.fen(), lastMove)
                } else {
                  console.error('Invalid computer move:', moveObj)
                }
              }
            })
          }
        })
        
        // Set up instructions and buttons
        // Set up DOM element references
        const whoseTurnEl = document.querySelector('.whose-turn')
        const goalEl = document.querySelector('.goal')
        const goalMessageEl = document.querySelector('.goal-message')
        const instructionsAreaEl = document.querySelector('.instructions-area')
        
        // Function to update turn indicator
        const updateTurnIndicator = (currentFen: string) => {
          if (whoseTurnEl) {
            // Always show "White to move" since player is White
            whoseTurnEl.textContent = 'White to move'
          }
        }
        
        const setupUI = () => {
          // Dispatch initial position setup
          console.log('Setting initial FEN:', fen)
          dispatch('fen:set', fen)
          
          // Set initial turn indicator
          if (position.fen) {
            updateTurnIndicator(position.fen)
            
            // Set initial fade state - start with "White to move" visible
            if (instructionsAreaEl) {
              instructionsAreaEl.classList.remove('faded')
            }
          }
          
          if (goalEl && position.goal) {
            goalEl.textContent = position.goal === 'win' ? 'Play and win' : 'Play and draw'
          }
          
          // Set up reset button
          const resetBtn = document.querySelector('.reset-position')
          if (resetBtn && position) {
            resetBtn.addEventListener('click', () => {
              dispatch('position:reset')
            })
          }
          
          // Set up analyze button
          const analyzeBtn = document.querySelector('.analyze-lichess')
          if (analyzeBtn && position) {
            analyzeBtn.addEventListener('click', () => {
              const lichessUrl = `https://lichess.org/analysis/${position.fen.replace(/ /g, '_')}`
              window.open(lichessUrl, '_blank')
            })
          }
          
          // Make initial computer move to show it's the player's turn
          if (!initialMoveMade) {
            initialMoveMade = true
            setTimeout(() => {
              console.log('Making initial computer move...')
              const analysisOptions = { depth, multipv: 1 }
              engine.analyze(fen, analysisOptions).then(output => {
                const { state } = output
                if (state && state.evaluation && state.evaluation.best) {
                  const computerMove = state.evaluation.best
                  console.log('Initial computer move:', computerMove)
                  
                  // Convert UCI move to proper format for ChessgroundBoard
                  const moveObj = uciToMove(computerMove)
                  console.log('Converted move object:', moveObj)
                  
                  // Use the board's move method directly instead of dispatch
                  const moveResult = board.cjs.move(moveObj)
                  if (moveResult) {
                    // Update the board display with lastMove highlighting
                    const lastMove = [moveObj.from, moveObj.to] as [string, string]
                    dispatch('fen:set', board.cjs.fen(), lastMove)
                    
                    // Update instructions to show it's now the player's turn
                    if (whoseTurnEl) {
                      const playerToMove = position.fen.includes(' w ') ? 'Black' : 'White'
                      whoseTurnEl.textContent = `${playerToMove} to move`
                    }
                  } else {
                    console.error('Invalid move:', moveObj)
                  }
                }
              }).catch(error => {
                console.error('Error making initial computer move:', error)
              })
            }, 500) // Small delay to ensure board is fully initialized
          }
        }
        
        // Set up UI when DOM is ready
        if (document.readyState === 'loading') {
          document.addEventListener('DOMContentLoaded', setupUI)
        } else {
          setupUI()
        }
        
        // Also use setTimeout as a fallback
        setTimeout(setupUI, 100)
      }
      
      // Wait for DOM to be ready
      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initializeBoard)
      } else {
        initializeBoard()
      }
    })
  },

  // new puzzle player
  "pages#puzzle_player": () => mountVue(NewPuzzlePlayer, '.vue-app-mount'),

  // quest puzzle player
  "game_modes/quest#play_quest_level": () => mountVue(QuestMode, '.quest-mode .vue-app-mount'),

  // adventure puzzle player
  "game_modes/adventure#play_level": () => mountVue(AdventureMode, '.adventure-mode .vue-app-mount'),

  // user profile
  "users#customize_board": () => new CustomizeBoard,
  "users#show": () => UserProfile(),
  "users#me": () => UserProfile(),
}

export default routes
