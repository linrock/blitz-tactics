import axios, { AxiosRequestConfig, AxiosPromise } from 'axios'

const headersWithCsrfToken = (): AxiosRequestConfig => {
  const token: string = document
    .querySelector('meta[name="csrf-token"]')
    .getAttribute('content')
  return {
    headers: {
      'X-CSRF-Token': token
    }
  }
}

export default {
  get(path: string): AxiosPromise {
    return axios.get(path)
  },
  post(path: string, data = {}): AxiosPromise {
    return axios.post(path, data, headersWithCsrfToken())
  },
  put(path: string, data): AxiosPromise {
    return axios.put(path, data, headersWithCsrfToken())
  },
  patch(path: string, data): AxiosPromise {
    return axios.patch(path, data, headersWithCsrfToken())
  }
}
