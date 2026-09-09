#!/usr/bin/env ruby
# Wire the AlarmKit pieces into both targets: the shared metadata type into the
# app and the widget, and the alarm's opening clip into the app bundle.
require 'xcodeproj'

ROOT = File.expand_path('..', __dir__)
proj = Xcodeproj::Project.open(File.join(ROOT, 'MorningReset/MorningReset.xcodeproj'))
app    = proj.targets.find { |t| t.name == 'MorningReset' }       or abort 'app target not found'
widget = proj.targets.find { |t| t.name == 'MorningResetWidget' } or abort 'widget target not found'

data = proj.main_group.find_subpath('Data', false) or abort 'Data group not found'
unless data.children.any? { |c| c.display_name == 'AlarmMeta.swift' }
  ref = data.new_reference('AlarmMeta.swift')
  app.add_file_references([ref])
  widget.add_file_references([ref])
  puts 'AlarmMeta.swift -> app + widget'
end

res = proj.main_group.find_subpath('Resources', false) or abort 'Resources group not found'
unless res.children.any? { |c| c.display_name == 'wake_opening.caf' }
  ref = res.new_reference('wake_opening.caf')
  app.add_resources([ref])
  puts 'wake_opening.caf -> app resources'
end
proj.save
