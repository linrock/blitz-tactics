// interactive chessboaard with piece promotion modal and move status

import Chessboard from '../chessboard/chessboard.ts'
import MoveStatus from './views/move_status.ts'
import PiecePromotionModal from './views/piece_promotion_modal.ts'

export default class InteractiveBoard {
  constructor() {
    new Chessboard
    new MoveStatus
    new PiecePromotionModal
  }
}
