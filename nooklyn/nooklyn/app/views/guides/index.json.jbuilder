json.array!(@guides) do |guide|
  json.extract! guide, :id, :neighborhood_id, :title, :description, :pull_quote, :pull_quote_author
  json.url guide_url(guide, format: :json)
end
