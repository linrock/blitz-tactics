// interactive chessboaard with piece promotion modal and move status

import Chessboard from '../chessboard/chessboard'
import MoveStatus from './views/move_status'
import PiecePromotionModal from './views/piece_promotion_modal'

export default class InteractiveBoard {
  constructor(options = {}) {
    new Chessboard
    if (!options.noCombo) {
      new MoveStatus
    }
    new PiecePromotionModal
  }
}
