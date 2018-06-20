// interactive chessboaard with piece promotion modal and move status

import Chessboard from './chessboard'
import MoveStatus from './interactive_board/move_status'
import PiecePromotionModal from './interactive_board/piece_promotion_modal'

export default class InteractiveBoard {
  constructor() {
    new Chessboard
    new MoveStatus
    new PiecePromotionModal
  }
}
