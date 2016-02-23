FactoryGirl.define do
  factory :job_application do
    full_name "Stan Rizzo"
    email "srizzo@scdp.com"
    phone "232-343-2299"
    current_company "Sterling Cooper Draper Pryce"
    position "Rental Agent"
    resume_file_name "stan_rizzume.pdf"
    resume_content_type "application/pdf"
  end
end
