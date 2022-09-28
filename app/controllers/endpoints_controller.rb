class EndpointsController < ApplicationController
  before_action :set_endpoint, only: %i[show update destroy]

  # GET /endpoints
  def index
    @endpoints = Endpoint.all

    render json: { data: endpoints_wrapper }
  end

  # GET /endpoints/1
  def show
    render json: { data: endpoint_wrapper(@endpoint) }
  end

  # POST /endpoints
  def create
    @endpoint = Endpoint.new(params_wrapper)

    if @endpoint.save && params[:data][:type] == 'endpoints'
      render json: { data: endpoint_wrapper(@endpoint) }, status: :created, location: @endpoint
    else
      render json: @endpoint.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /endpoints/1
  def update
    if @endpoint.update(params_wrapper)
      render json: { data: endpoint_wrapper(@endpoint) }
    else
      render json: @endpoint.errors, status: :unprocessable_entity
    end
  end

  # DELETE /endpoints/1
  def destroy
    @endpoint.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_endpoint
    @endpoint = Endpoint.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: generate_error, status: :not_found
  end

  # Only allow a list of trusted parameters through.
  def endpoint_params
    params.require(:data).permit(:type, attributes: [:verb, :path, { response: [:code, :body, { headers: {} }] }])
  end

  def params_wrapper
    attr = endpoint_params[:attributes]
    {
      verb: attr[:verb].to_s.downcase,
      path: attr[:path],
      code: attr[:response][:code],
      headers: attr[:response][:headers],
      body: attr[:response][:body]
    }
  end

  def endpoint_wrapper(endpoint)
    {
      type: 'endpoints',
      id: endpoint.id,
      attributes: {
        verb: endpoint.verb.upcase,
        path: endpoint.path,
        response: { code: endpoint.code, headers: endpoint.headers, body: endpoint.body }
      }
    }
  end

  def endpoints_wrapper
    endpoints_params = []
    @endpoints.each do |endpoint|
      endpoints_params << endpoint_wrapper(endpoint)
    end
    endpoints_params
  end

  def generate_error
    { errors: [
      {
        "code": 'not_found',
        "detail": "Requested Endpoint with ID #{params[:id]} does not exist"
      }
    ] }
  end
end
