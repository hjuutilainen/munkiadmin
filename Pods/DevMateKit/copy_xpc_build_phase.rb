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

# !!! NOTE
# Now DevMate XPC service is part of DevMateKit.framework.
# Because of that we need to remmove build phase that copies XPC service.
if (phase_added)
    xpc_phase.files_references.each { |file_ref|
        puts "Removing unneeded xpc-service: #{file_ref.path}"
        xpc_phase.remove_file_reference(file_ref)
        file_ref.remove_from_project
    }
    
    puts "Removing obsolete copy-XPC-files build phase"
    xpc_phase.remove_from_project()
end
project.save()
