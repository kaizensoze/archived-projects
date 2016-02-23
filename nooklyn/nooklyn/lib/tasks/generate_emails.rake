namespace :agents do
  desc 'Generates emails for users who do not have an email'
  task generate_emails: :environment do
    Agent.all.each do |agent|
      if agent.email.blank?
        formatted_firstname = agent.first_name.downcase.strip.gsub(/[^a-z0-9\s]/i, '').gsub(/\s/i, '-')
        formatted_lastname = agent.last_name.downcase.strip.gsub(/[^a-z0-9\s]/i, '').gsub(/\s/i, '-')
        formatted_agent_id = agent.id
        agent.email = "#{formatted_firstname}.#{formatted_lastname}-#{formatted_agent_id}@nooklyn.net"
        agent.save
      end
    end
  end
end
