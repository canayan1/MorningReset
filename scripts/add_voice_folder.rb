#!/usr/bin/env ruby
# Add Resources/Voice to the app target as a folder reference, the same way
# Resources/Schools is wired: a blue folder copied wholesale into the bundle, so
# a new clip needs no project edit — only a re-run of the voice build.
require 'xcodeproj'

ROOT = File.expand_path('..', __dir__)
proj = Xcodeproj::Project.open(File.join(ROOT, 'MorningReset/MorningReset.xcodeproj'))
target = proj.targets.find { |t| t.name == 'MorningReset' } or abort 'target not found'
group = proj.main_group.find_subpath('Resources', false) or abort 'Resources group not found'

if group.children.any? { |c| c.display_name == 'Voice' }
  puts 'Voice already referenced'
else
  ref = group.new_reference('Voice')
  ref.last_known_file_type = 'folder'
  ref.name = 'Voice'
  target.add_resources([ref])
  proj.save
  puts 'Voice folder reference added'
end
