Pod::Spec.new do |s|
  s.name             = 'GazeTracker'
  s.version          = '0.1.0'
  s.summary          = 'A short description of GazeTracker.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ReQEnoxus/GazeTracker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ReQEnoxus' => 'reqenoxus@gmail.com' }
  s.source           = { :git => 'https://github.com/ReQEnoxus/GazeTracker.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.source_files = 'GazeTracker/Classes/**/*'
  
  # s.resource_bundles = {
  #   'GazeTracker' => ['GazeTracker/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end