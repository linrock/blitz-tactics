import axios from 'axios'

class APIClient {

  post(path, data) {
    const token = document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute('content')
    return axios.post(path, data, {
      headers: {
        'X-CSRF-Token': token
      }
    })
  }

  get(path) {
    return axios.get(...arguments)
  }
}

const api = new APIClient

export default api
