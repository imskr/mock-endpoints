# Any request that is not 'endpoints' request, enters into `echo` method
# `echo` method returns a page with corresponding path/verb if it exists in Endpoint table
class ApplicationController < ActionController::API
  def echo
    @endpoint = Endpoint.find_by path: request.path, verb: request.method_symbol

    if @endpoint
      render json: @endpoint.body, status: @endpoint.code, headers: @endpoint.headers
    else
      render json: generate_error, status: :not_found
    end
  end

  private

  def generate_error
    { errors: [
      {
        "code": 'not_found',
        "detail": "Requested page `#{request.path}` does not exist"
      }
    ] }
  end
end
