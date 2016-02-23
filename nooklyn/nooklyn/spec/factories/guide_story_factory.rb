FactoryGirl.define do
  factory :guide_story do
    guide

    title "Three Diamond Door"
    description "Dog-friendly bar with lots of outdoor seating"
    image_file_name "3diamonddoor.jpg"
    image_content_type "image/jpg"
  end
end
