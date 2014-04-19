require 'json'

module Example
  module Models
    class User

      attr_accessor :first_name, :last_name

      def initialize attributes
        attributes.each_pair do | key, value |
          send("#{key}=", value)
        end
      end

      def to_json
        {firstName: first_name, lastName: last_name}.to_json
      end

      def self.find_by_id id
        raise NotImplementedError
      end

    end
  end
end