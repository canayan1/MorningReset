#!/usr/bin/env ruby
require 'xcodeproj'
ROOT = File.expand_path('..', __dir__)
proj = Xcodeproj::Project.open(File.join(ROOT, 'MorningReset/MorningReset.xcodeproj'))
target = proj.targets.find { |t| t.name == 'MorningReset' } or abort 'app target not found'
group = proj.main_group.find_subpath('Data', false) or abort 'Data group not found'
file = 'PulseSignal.swift'
if group.children.any? { |c| c.display_name == file }
  puts "#{file} already referenced"
else
  target.add_file_references([group.new_reference(file)])
  proj.save
  puts "#{file} -> app target"
end
