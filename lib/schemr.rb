$LOAD_PATH.unshift File.dirname(__FILE__) unless $LOAD_PATH.include?(File.dirname(__FILE__))

module Schemr; end

require 'util'
require 'dsl'
require 'dom'
require 'render'