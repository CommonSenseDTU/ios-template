# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'template' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Use local musli when available
  if File.exist? "../musli/musli.podspec"
    pod 'musli', :path => "../musli"
  else
    pod 'musli'
  end

  # Use local Granola when available
  if File.exist? "../Granola/Granola.podspec"
    pod 'Granola', :path => "../Granola"
  end

end
