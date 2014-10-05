require 'mongoid'

module SimpleTokenAuthentication
  module Adapters
    class MongoidAdapter
      extend SimpleTokenAuthentication::Adapter

      def self.models_base_class
        ::Mongoid::Document
      end
    end
  end
end
