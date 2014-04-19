require 'webmachine'
require 'webmachine/adapters/rack'
require 'example/api/resources/user'

module Example

  API ||= begin
    example_api = Webmachine::Application.new do |app|
      app.routes do
        add(['trace', '*'], Webmachine::Trace::TraceResource) unless ENV['RACK_ENV'] == 'production'
        add ['users', :id], Example::Api::Resources::User
      end
    end

    example_api.configure do |config|
      config.adapter = :Rack
    end

    example_api.adapter
  end

end