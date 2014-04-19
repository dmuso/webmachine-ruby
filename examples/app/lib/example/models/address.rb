require 'json'

module Example
  module Models
    class Address

      attr_accessor :street, :city

      def initialize attributes
        attributes.each_pair do | key, value |
          send("#{key}=", value)
        end
      end

      def to_json
        {street: street, city: city}.to_json
      end

      def self.find_by_user_id id
        raise NotImplementedError
      end

    end
  end
end