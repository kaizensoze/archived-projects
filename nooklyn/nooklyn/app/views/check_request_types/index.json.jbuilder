json.array!(@check_request_types) do |check_request_type|
  json.extract! check_request_type, :id, :name, :active
  json.url check_request_type_url(check_request_type, format: :json)
end
