#!/usr/bin/env ruby
# Wire the breath detector and the signature practice into the app target.
require 'xcodeproj'

ROOT = File.expand_path('..', __dir__)
proj = Xcodeproj::Project.open(File.join(ROOT, 'MorningReset/MorningReset.xcodeproj'))
target = proj.targets.find { |t| t.name == 'MorningReset' } or abort 'app target not found'

{ 'Data' => 'BreathDetector.swift', 'Screens' => 'SignatureMeditationView.swift' }.each do |group_name, file|
  group = proj.main_group.find_subpath(group_name, false) or abort "#{group_name} group not found"
  next puts("#{file} already referenced") if group.children.any? { |c| c.display_name == file }
  target.add_file_references([group.new_reference(file)])
  puts "#{file} -> app target"
end
proj.save
