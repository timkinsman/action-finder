# frozen_string_literal: true

require 'octokit'
require 'tty-spinner'

def check_rate_limit(user, pass, x, spinner)
    client = Octokit::Client.new(login: user, password: pass)
    if client.rate_limit.remaining <= x
        spinner.error('ERROR: Rate limit exceeded!')
        spinner = TTY::Spinner.new("[:spinner] Rate limit resets in #{client.rate_limit.resets_in + 5} seconds ...", format: :classic)
        spinner.auto_spin

        sleep(client.rate_limit.resets_in + 5)

        spinner.success
    end
    client
end
