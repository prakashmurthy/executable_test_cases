#!/usr/bin/env ruby
require 'bundler/inline'

gemfile true do
 source 'https://rubygems.org'
 gem 'colorize'
end

puts '* * * * * * '.white.on_blue + '1111111111111111111111111111111111111111111'.red.on_red
puts ' * * * * *  ' + '0000000000000000000000000000000000000000000'.white.on_white
puts '* * * * * * ' + '1111111111111111111111111111111111111111111'.red.on_red
puts ' * * * * *  ' + '0000000000000000000000000000000000000000000'.white.on_white
puts '* * * * * * ' + '1111111111111111111111111111111111111111111'.red.on_red
puts ' * * * * *  ' + '0000000000000000000000000000000000000000000'.white.on_white
puts '* * * * * * ' + '1111111111111111111111111111111111111111111'.red.on_red
puts '0000000000000000000000000000000000000000000000000000000'.white.on_white
puts '1111111111111111111111111111111111111111111111111111111'.red.on_red
puts '0000000000000000000000000000000000000000000000000000000'.white.on_white
puts '1111111111111111111111111111111111111111111111111111111'.red.on_red
puts '0000000000000000000000000000000000000000000000000000000'..white.on_white
puts '1111111111111111111111111111111111111111111111111111111'.red.on_red
