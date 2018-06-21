import axios from 'axios'

class APIClient {

  get(path) {
    return axios.get(...arguments)
  }

  post(path, data) {
    return axios.post(path, data, this.headersWithCsrfToken())
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
