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

  s.ios.deployment_target = '13.4'

  s.source_files = 'GazeTracker/Classes/**/*'
  
  s.dependency 'DeviceKit', '~> 4.0'
end
