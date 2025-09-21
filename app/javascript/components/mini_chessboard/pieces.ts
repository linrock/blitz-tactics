import m from 'mithril'

interface PieceAttributes {
  oncreate?: (vnode: m.Component) => void
}

export default function virtualPiece(piece, oncreate = null): m.Component {
  const pieceAttrs: PieceAttributes = {}
  if (oncreate) {
    pieceAttrs.oncreate = oncreate
  }
  
  // Map single character piece types to full names (matching CSS selectors)
  const pieceTypeMap: { [key: string]: string } = {
    'p': 'pawn',
    'b': 'bishop', 
    'n': 'knight',
    'r': 'rook',
    'q': 'queen',
    'k': 'king'
  }
  
  const fullPieceType = pieceTypeMap[piece.type] || piece.type
  const fullColorName = piece.color === 'w' ? 'white' : 'black'
  
  // Use CSS background images instead of inline SVG elements
  // Create piece elements like: <piece class="pawn white"> (matching .cg-wrap piece.pawn.white format)
  return m(`piece.${fullPieceType}.${fullColorName}`, pieceAttrs)
}
