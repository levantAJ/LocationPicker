Pod::Spec.new do |s|
  s.module_name = 'LocationPicker'
  s.name = 'LocationPicker'
  s.version = '0.0.1'
  s.license = 'MIT'
  s.summary = 'LocationPicker for @levantAJ team'
  s.homepage = 'https://github.com/levantAJ'
  s.authors = { 'Le Tai' => 'sirlevantai@gmail.com' }
  s.source = {  :git => 'https://github.com/levantAJ/LocationPicker.git', :tag => s.version}
  s.source_files = 'LocationPicker/**/*.{h,swift}'
  s.resources = "LocationPicker/**/*.{xib,storyboard,xcassets}"
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
end
