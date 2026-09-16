#!/usr/bin/env ruby
# Wire the pulse reader and its screen into the app target.
require 'xcodeproj'

ROOT = File.expand_path('..', __dir__)
proj = Xcodeproj::Project.open(File.join(ROOT, 'MorningReset/MorningReset.xcodeproj'))
target = proj.targets.find { |t| t.name == 'MorningReset' } or abort 'app target not found'

{ 'Data' => 'PulseReader.swift', 'Screens' => 'PulseCheckView.swift' }.each do |group_name, file|
  group = proj.main_group.find_subpath(group_name, false) or abort "#{group_name} group not found"
  if group.children.any? { |c| c.display_name == file }
    puts "#{file} already referenced"
    next
  end
  ref = group.new_reference(file)
  target.add_file_references([ref])
  puts "#{file} -> app target"
end
proj.save
