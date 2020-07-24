# frozen_string_literal: true

require 'octokit'

def login(user, pass) 
  client = Octokit::Client.new(login: user, password: pass)
  print 'Attempting to login ... '
  begin
    client.user
  rescue StandardError
    abort('Unsuccessful! (401 - Bad credentials)')
  end
  puts 'Successful!'
  client
end
