require 'json'

module Example
  module Models
    class User

      attr_accessor :first_name, :last_name, :address

      def initialize attributes
        attributes.each_pair do | key, value |
          send("#{key}=", value)
        end
      end

      def as_json
        {firstName: first_name, lastName: last_name, address: address}
      end

      def to_json
        as_json.to_json
      end

      def self.find_by_id id
        raise NotImplementedError
      end

    end
  end
end