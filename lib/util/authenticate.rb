# frozen_string_literal: true

require 'octokit'

def authenticate(user, pass)
  client = Octokit::Client.new(login: user, password: pass)
  begin
    client.user
  rescue StandardError
    abort('Unsuccessful! (401 - Bad credentials)')
  end
  client
end
