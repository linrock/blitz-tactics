import axios from 'axios'
import {
  AxiosRequestConfig,
  AxiosPromise,
} from 'axios'

const headersWithCsrfToken = (): AxiosRequestConfig => {
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

  get(path): AxiosPromise {
    return axios.get(path)
  }

  post(path, data = {}): AxiosPromise {
    return axios.post(path, data, headersWithCsrfToken())
  }

  put(path, data): AxiosPromise {
    return axios.put(path, data, headersWithCsrfToken())
  }
}

const api = new APIClient

export default api
