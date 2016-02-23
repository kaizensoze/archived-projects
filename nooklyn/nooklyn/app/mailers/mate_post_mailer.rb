class MatePostMailer < ActionMailer::Base
  default from: "Nooklyn <help@nooklyn.com>"

  def about_to_expire(mate_post)
    @agent = mate_post.agent
    mail to: "#{@agent.first_name} <#{@agent.email}>", subject: 'Nooklyn: Did you find a roommate?'
  end
end
