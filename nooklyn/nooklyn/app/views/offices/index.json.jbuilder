json.array!(@offices) do |office|
  json.extract! office, :id, :name, :address_line_one, :address_line_two, :city, :state, :zip_code
  json.url office_url(office, format: :json)
end
