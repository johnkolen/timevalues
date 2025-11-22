# frozen_string_literal: true

require 'active_support/core_ext/object/deep_dup'

require_relative "timevalues/version"
require_relative "timevalues/time_value"
require_relative "timevalues/time_value_history"
require_relative "timevalues/composition_xform"
require_relative "timevalues/dupable"
require_relative "timevalues/linear_xform"
require_relative "timevalues/network"
require_relative "timevalues/sigmoid_xform"
require_relative "timevalues/trainer"
require_relative "timevalues/units"
require_relative "timevalues/xform"

module Timevalues
  class Error < StandardError; end
  # Your code goes here...
end
