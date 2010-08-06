# how to guarantee user is created already confirmed?
Factory.define :user do |u|

  class User < ActiveRecord::Base
    attr_accessible :first_ip, :last_ip, :state, :activation_code
  end
  u.login { Factory.next(:login) }
  u.email { Factory.next(:email) }
  u.password 'password'
  u.password_confirmation 'password'
  u.state 'active'
  u.first_ip '127.0.0.2'
  u.last_ip '127.0.0.3'
  u.activation_code {User.make_token}
  u.locale 'en'
end

Factory.sequence :login do |n| 
  "user#{n}"
end

Factory.sequence :email do |n|
  "useremail#{n}@example.com"
end
