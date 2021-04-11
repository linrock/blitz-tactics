// https://github.com/marcuswestin/store.js

import engine from 'store/src/store-engine'
import localStorage from 'store/storages/localStorage'
import cookieStorage from 'store/storages/cookieStorage'
import expire from 'store/plugins/expire'

const storages = [localStorage, cookieStorage]
const plugins = [expire]

const store = engine.createStore(storages, plugins)

export default store
