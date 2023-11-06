require 'active_record'

class User < ActiveRecord::Base
    has_many :captured_media
end

class CapturedMedia < ActiveRecord::Base
    belongs_to :user
end


