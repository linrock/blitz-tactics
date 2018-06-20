import axios from 'axios'

class APIClient {

  post(path, data) {
    return axios.post(path, data, this.headersWithCsrfToken())
  }

  get(path) {
    return axios.get(...arguments)
  }

  put(path, data) {
    return axios.put(path, data, this.headersWithCsrfToken())
  }

  headersWithCsrfToken() {
    const token = document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute('content')
    return {
      headers: {
        'X-CSRF-Token': token
      }
    }
  }
}

const api = new APIClient

export default api
