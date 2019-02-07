import m from 'mithril'

interface PieceAttributes {
  oncreate?: (vnode: m.Component) => void
}

export default function virtualPiece(piece, oncreate = null): m.Component {
  const className: string = piece.color + piece.type
  const pieceAttrs: PieceAttributes = {}
  if (oncreate) {
    pieceAttrs.oncreate = oncreate
  }
  return m(`div.piece.${className}.${piece.color}`, pieceAttrs, [
    m(`svg`, { viewBox: `0 0 45 45` }, [
      m(`use`, {
        'xlink:href': `#${className}`,
        width: `100%`,
        height: `100%`
      })
    ])
  ])
}
