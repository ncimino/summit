# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Page.create(:name => 'Home', :title => 'Welcome to Home!', :content => '<h2>Content</h2>This is the content of the home page...', :location => 'topbar', :url => '', :ordinal => '1')
