require 'rails_helper'
require 'factories/endpoint'

RSpec.describe 'Endpoints', type: :request do
  let(:valid_params) do
    { data: { type: 'endpoints',
              attributes: {
                path: '/hello/world', verb: 'GET',
                response: { body: '"{ "message": "Hello world" }"', code: 200, headers: {} }
              } } }
  end

  describe 'GET /endpoints' do
    let(:endpoint1) { create(:endpoint) }
    let(:endpoint2) { create(:endpoint, path: '/hello2/world') }

    it 'returns all endpoints' do
      expect(endpoint1.id).to eq(1)
      expect(endpoint2.id).to eq(2)

      get '/endpoints'
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['data'].size).to eq(2)
      expect(JSON.parse(response.body)['data'][1]['attributes']['path']).to eq(endpoint2.path)
    end
  end

  describe 'GET /endpoints/:id' do
    let(:endpoint1) { create(:endpoint) }

    it 'returns endpoint with corresponding id' do
      expect(endpoint1.id).to eq(1)
      get '/endpoints/1'

      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['data']['attributes']['path']).to eq(endpoint1.path)
    end

    it 'returns error when id does not exist' do
      get '/endpoints/1'

      expect(response).to have_http_status(404)
      expect(JSON.parse(response.body)['errors'][0]['detail']).to eq("Requested Endpoint with ID #{endpoint1.id} does not exist")
    end
  end

  describe 'POST /endpoint' do
    it 'creates a new endpoint with valid parameters' do
      expect do
        post '/endpoints', params: valid_params
      end.to change { Endpoint.count }.from(0).to(1)

      expect(response).to have_http_status(201)
      expect(JSON.parse(response.body)['data']['attributes']['path']).to eq('/hello/world')
      expect(JSON.parse(response.body)['data']['id']).to eq(1)
    end

    context 'when invalid parameters passed' do
      context 'when type is not `endpoints`' do
        let(:invalid_params) do
          valid_params[:data][:type] = 'some_type'
          valid_params
        end

        it 'returns the error' do
          post '/endpoints', params: invalid_params
          expect(response).to have_http_status(422)
        end
      end

      context 'when verb is not get,post,patch or delete' do
        let(:invalid_params) do
          valid_params[:data][:attributes][:verb] = 'some_verb'
          valid_params
        end

        it 'returns the error' do
          post '/endpoints', params: invalid_params
          expect(response).to have_http_status(422)
          expect(JSON.parse(response.body)['verb'][0]).to eq('is not included in the list')
        end
      end

      context 'when code is not valid' do
        let(:invalid_params) do
          valid_params[:data][:attributes][:response][:code] = 1000
          valid_params
        end

        it 'returns the error' do
          post '/endpoints', params: invalid_params
          expect(response).to have_http_status(422)
          expect(JSON.parse(response.body)['code'][0]).to eq('is not included in the list')
        end
      end

      context 'when path and verb already exist' do
        it 'returns the error' do
          post '/endpoints', params: valid_params
          post '/endpoints', params: valid_params
          expect(response).to have_http_status(422)
          expect(JSON.parse(response.body)['verb'][0]).to eq('has already been taken')
        end
      end
    end
  end

  describe 'PATCH /endpoint' do
    let(:endpoint1) { create(:endpoint) }
    let(:update_params) do
      valid_params[:data][:attributes][:path] = '/changed_path'
      valid_params
    end

    it 'updates an endpoint' do
      expect(endpoint1.id).to eq(1)
      expect(endpoint1.path).to eq('/hello/world')

      patch '/endpoints/1', params: update_params
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['data']['attributes']['path']).to eq(update_params[:data][:attributes][:path])
    end
  end

  describe 'DELETE /endpoint/:id' do
    let(:endpoint1) { create(:endpoint) }
    let(:valid_id) { endpoint1.id }
    let(:invalid_id) { 2 }

    it 'deletes an endpoint when valid id passed' do
      expect(endpoint1.id).to eq(1)

      delete "/endpoints/#{valid_id}"
      expect(response).to have_http_status(204)
    end

    it 'returns an error when invalid id passed' do
      delete "/endpoints/#{invalid_id}"
      expect(response).to have_http_status(404)
      expect(JSON.parse(response.body)['errors'][0]['detail'])
        .to eq("Requested Endpoint with ID #{invalid_id} does not exist")
    end
  end
end
