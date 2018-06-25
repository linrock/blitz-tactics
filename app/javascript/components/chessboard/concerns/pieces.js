import m from 'mithril'

export default function virtualPiece(piece, oncreate) {
  const className = piece.color + piece.type
  const pieceAttrs = {}
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
