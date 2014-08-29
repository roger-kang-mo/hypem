class Email < ActiveRecord::Base
  attr_accessible :email, :plan, :comment
end