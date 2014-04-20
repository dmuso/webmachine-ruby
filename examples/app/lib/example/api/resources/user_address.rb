require 'webmachine'
require 'example/models/address'

module Example
  module Api
    module Resources
      class UserAddress < Webmachine::Resource

        def allowed_methods
          ["GET", "PATCH"]
        end

        def content_types_provided
          [["application/json", :to_json]]
        end

        def content_types_accepted
          [["application/json-patch+json", :patch_json, "PATCH"]]
        end

        def allow_missing_patch?
          user != nil # Allow patch to a missing address if the user already exists
        end

        def patch_json
          # Not sure about the elegant way to do this
          unless @address
            # This should be in a repository of course... but for the sake of the example, do it here...
            @address = Example::Models::Address.new
            @address.save
            user.address = @address
            user.save
            response.headers['Location'] = request.uri
          end

          @address.update_attributes request_body
          response.body = @address.to_json
          true
        end

        def to_json
          @address.to_json
        end

        def resource_exists?
          (user != nil && user.address != nil).tap do | exists |
            @address = user.address if exists
          end
        end

        def user
          @user ||= Example::Models::User.find_by_id(request.path_info[:id])
        end

        def request_body
          JSON.parse(request.body.to_s)
        end

      end
    end
  end
end