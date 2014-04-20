require 'webmachine'
require 'example/models/user'

module Example
  module Api
    module Resources
      class User < Webmachine::Resource

        def allowed_methods
          ["GET", "PATCH"]
        end

        def content_types_provided
          [["application/json", :to_json]]
        end

        def content_types_accepted
          [["application/xml", :from_xml],
          ["application/json-patch+json", :patch_json, "PATCH"]]
        end

        def patch_json
          @user.update_attributes request_body
          response.body = @user.to_json
          true
        end

        def from_xml
          raise NotImplementedError
        end

        def to_json
          @user.to_json
        end

        def resource_exists?
          @user = Example::Models::User.find_by_id(request.path_info[:id])
          @user != nil
        end

        def request_body
          JSON.parse(request.body.to_s)
        end

      end
    end
  end
end