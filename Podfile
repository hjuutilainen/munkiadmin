platform :osx, '10.8'

target 'MunkiAdmin' do
pod 'NSHash', '~> 1.0.1'
pod 'CocoaLumberjack'
pod 'PXSourceList', '~> 2.0'
pod 'DevMateKit'
pod 'CHCSVParser', '~> 2.1'
end

post_install do |installer|
    system("RUBY_SCRIPT='Pods/DevMateKit/copy_xpc_build_phase.rb'; if [ -f $RUBY_SCRIPT ]; then ruby $RUBY_SCRIPT '#{path}'; fi")
end
