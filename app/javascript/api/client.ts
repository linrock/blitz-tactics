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

class APIClient {

  public get(path: string): AxiosPromise {
    return axios.get(path)
  }

  public post(path: string, data = {}): AxiosPromise {
    return axios.post(path, data, headersWithCsrfToken())
  }

  public put(path: string, data): AxiosPromise {
    return axios.put(path, data, headersWithCsrfToken())
  }

  public patch(path: string, data): AxiosPromise {
    return axios.patch(path, data, headersWithCsrfToken())
  }
}

const api = new APIClient

export default api
