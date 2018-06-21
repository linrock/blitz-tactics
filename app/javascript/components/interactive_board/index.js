// interactive chessboaard with piece promotion modal and move status

import Chessboard from '../chessboard/chessboard'
import MoveStatus from './views/move_status'
import PiecePromotionModal from './views/piece_promotion_modal'

export default class InteractiveBoard {
  constructor() {
    new Chessboard
    new MoveStatus
    new PiecePromotionModal
  }
}
