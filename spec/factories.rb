Factory.define :user do |f|
  f.sequence(:email) { |n| "foo#{n}@example.com" }
  f.first_name 'Foo'
  f.last_name 'Bar'
  f.password 'secret'
  f.password_confirmation 'secret'
end
