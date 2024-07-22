# frozen_string_literal: true

require "spec_helper"

class User < ActiveRecord::Base
  include CoreMerchant::CustomerBehavior
end
