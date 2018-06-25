import m from 'mithril'

export default function virtualPiece(piece, oncreate) {
  const className = piece.color + piece.type
  const svgAttrs = { viewBox: `0 0 45 45` }
  if (oncreate) {
    Object.assign(svgAttrs, { oncreate })
  }
  return m(
    `svg.piece.${className}.${piece.color}`, svgAttrs, [
      m(`use`, {
        'xlink:href': `#${className}`,
        width: `100%`,
        height: `100%`
      })
    ]
  )
}
