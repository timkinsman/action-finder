# frozen_string_literal: true

require 'octokit'

def authenticate(token)
  client = Octokit::Client.new(access_token: token)
  begin
    client.user
  rescue StandardError
    abort('Unsuccessful! (401 - Bad credentials)')
  end
  client
end
