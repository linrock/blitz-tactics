import axios from 'axios'

const headersWithCsrfToken = () => {
  const token = document
    .querySelector('meta[name="csrf-token"]')
    .getAttribute('content')
  return {
    headers: {
      'X-CSRF-Token': token
    }
  }
}

class APIClient {

  get(path) {
    return axios.get(...arguments)
  }

  post(path, data) {
    return axios.post(path, data, headersWithCsrfToken())
  }

  put(path, data) {
    return axios.put(path, data, headersWithCsrfToken())
  }
}

const api = new APIClient

export default api
