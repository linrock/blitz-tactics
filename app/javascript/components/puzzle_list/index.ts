import store from '@blitz/local_storage'

// If the player made mistakes, marks puzzles in the list as having mistakes
export default () => {
  console.log('puzzles#index init')
  const data = store.get(window.location.pathname)
  if (!data) {
    console.log('no puzzle info found in localStorage')
    return
  }
  console.dir(data)
  Object.entries(data).forEach(([puzzleId, mistakes]) => {
    const puzzleEl = document.querySelector(`[data-puzzle-id="${puzzleId}"]`)
    console.dir(mistakes)
    if (puzzleEl) {
      const puzzleMistakeInfoEl: HTMLElement = puzzleEl.querySelector('.puzzle-mistake-info')
      if (puzzleMistakeInfoEl) {
        const nMistakes = (mistakes as string[]).length
        puzzleMistakeInfoEl.textContent = `${nMistakes} mistake${nMistakes > 1 ? 's' : ''}`
      }
    }
  })
}
