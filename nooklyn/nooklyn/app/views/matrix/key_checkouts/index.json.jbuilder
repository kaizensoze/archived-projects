json.array!(@key_checkouts) do |key_checkout|
  json.extract! key_checkout, :id, :message, :agent_id, :returned
  json.url key_checkout_url(key_checkout, format: :json)
end
