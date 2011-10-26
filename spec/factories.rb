Factory.define :user do |f|
  f.sequence(:email) { |n| "foo#{n}@example.com" }
  f.first_name 'Foo'
  f.last_name 'Bar'
  f.password 'secret'
  f.password_confirmation 'secret'
end

Factory.define :key do |f|
  f.sequence(:title) { |n| "Test Key ##{n}" }
  f.password 'secret'
  f.password_confirmation 'secret'
end

Factory.define :certificate do |f|
  f.sequence(:title) { |n| "Test Certificate ##{n}" }
  f.sequence(:common_name) { |n| "Test Certificate ##{n}" }
  f.key_password 'secret'
  f.email 'foo@example.com'
  f.days 365
  f.organization 'Test lab'
  f.organization_unit 'Test lab CA'
  f.state 'Test state'
  f.locality 'Test locality'
  f.country 'Test country'
end

Factory.define :page do |f|
  f.sequence(:title) { |n| "Test Page ##{n}" }
  f.sequence(:body) { |n| "Test Page Content ##{n}" }
end
