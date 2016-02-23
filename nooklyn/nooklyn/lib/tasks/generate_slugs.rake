namespace :agents do
  desc 'Generates Slugs for users'
  task slugs: :environment do
    Agent.all.each do |agent|
      formatted_firstname = agent.first_name.downcase.strip.gsub(/[^a-z0-9\s]/i, '').gsub(/\s/i, '-')
      formatted_lastname = agent.last_name.downcase.strip.gsub(/[^a-z0-9\s]/i, '').gsub(/\s/i, '-')
      formatted_agent_id = agent.id
      agent.slug = "#{formatted_agent_id}-#{formatted_firstname}-#{formatted_lastname}"
      agent.save!
    end
  end
end
