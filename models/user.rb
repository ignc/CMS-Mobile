require 'data_mapper'

class CMS
  module Models
    class User
      include DataMapper::Resource
      property :id, Serial
      property :name, String, :required => true, :unique => true
      property :email, String, :required => true, :unique => true
      property :password, BCryptHash, :required => true
      property :created_at, DateTime

      validates_format_of :email, :as => :email_address
      validates_length_of :password, :min => 5

      def authenticate(attempted_password)
        if self.password == attempted_password
          true
        else
          false
        end
      end
    end
  end
end