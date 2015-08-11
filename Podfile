platform :osx, '10.8'

target 'MunkiAdmin' do
pod 'NSHash', '~> 1.0.1'
pod 'CocoaLumberjack', '2.0.0-rc'
pod 'PXSourceList', '~> 2.0'
pod 'DevMateKit'
end

post_install do |installer|
    system("RUBY_SCRIPT='Pods/DevMateKit/copy_xpc_build_phase.rb'; if [ -f $RUBY_SCRIPT ]; then ruby $RUBY_SCRIPT '#{path}'; fi")
end
