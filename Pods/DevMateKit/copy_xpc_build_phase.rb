#!/usr/bin/env ruby
 
require 'pathname'
require 'xcodeproj'
 
xcode_copy_phase_name = 'Copy DevMate XPC Services'

puts "Current project directory: #{Dir.pwd}"
path_to_project = Dir.glob(Pathname.new(Dir.pwd) + '*.xcodeproj')[0]
 
puts 'Path to main project: ' + path_to_project
 
project = Xcodeproj::Project.open(path_to_project)
main_target = project.targets.first
phase_added = false
xpc_phase = 0

main_target.copy_files_build_phases.each { |copy_phase|
  if (copy_phase.name == xcode_copy_phase_name)
    xpc_phase = copy_phase
    phase_added = true
  end
}
 
if (!phase_added)
  puts "Adding copy-XPC-files build phase in Xcode project #{path_to_project}"
  xpc_phase = main_target.new_copy_files_build_phase(xcode_copy_phase_name)
  xpc_phase.dst_subfolder_spec = '1' #:wrapper
  xpc_phase.dst_path = 'Contents/XPCServices'
else
  puts "Copy-XCP-files build phase already exists."
end

xpc_phase.files_references.each { |file_ref|
    puts "Removing previous xpc-service: #{file_ref.path}"
    xpc_phase.remove_file_reference(file_ref)
    file_ref.remove_from_project
}

Dir.glob(Pathname.new(Dir.pwd) + 'Pods/DevMateKit/*.xpc').each { |xpc_service|
    puts "Will add xpc-service: #{xpc_service}"
    xpc_phase.add_file_reference(project.new_file('Pods/DevMateKit/' + File.basename(xpc_service)), true)
}
project.save()
