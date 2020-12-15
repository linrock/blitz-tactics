// interactive chessboaard with piece promotion modal and move status

import Chessboard from '../chessboard/chessboard'
import MoveStatus from '../move_status'
import PiecePromotionModal from './views/piece_promotion_modal'

import './promo_modal.sass'

interface BoardOptions {
  noCombo?: boolean
}

export default class InteractiveBoard {
  constructor(options: BoardOptions = {}) {
    new Chessboard
    if (!options.noCombo) {
      new MoveStatus
    }
    new PiecePromotionModal
  }
}
