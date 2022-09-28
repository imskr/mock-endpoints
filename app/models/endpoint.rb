class Endpoint < ApplicationRecord
  validates :path, presence: true
  validates :verb, presence: true, inclusion: { in: %w[get post patch delete] }, uniqueness: { scope: :path }
  validates :code, presence: true, inclusion: { in: Rack::Utils::HTTP_STATUS_CODES }
end
