const uciToMove = uci => {
  const m = {
    from: uci.slice(0,2),
    to: uci.slice(2,4)
  }
  if (uci.length === 5) {
    m.promotion = uci[4]
  }
  return m
}

const moveToUci = move => {
  if (move.promotion) {
    return `${move.from}${move.to}${move.promotion}`
  } else {
    return `${move.from}${move.to}`
  }
}

const shuffle = original => {
  const array = original.slice(0)
  let counter = array.length
  while (counter > 0) {
    let index = Math.floor(Math.random() * counter)
    counter--
    let temp = array[counter]
    array[counter] = array[index]
    array[index] = temp
  }
  return array
}

export {
  uciToMove,
  moveToUci,
  shuffle,
}
