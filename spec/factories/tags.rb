FactoryGirl.define do
  factory :tag, class: ActsAsTaggableOn::Tag do
    id 1
    name 'happy'
    color 'orange'
  end
end
