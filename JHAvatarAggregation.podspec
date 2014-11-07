#
# Be sure to run `pod lib lint JHAvatarAggregation.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "JHAvatarAggregation"
  s.version          = "0.1.1"
  s.summary          = "Avatar polymerization showed in a UIImageView"
  s.homepage         = "https://github.com/caojianhua1741/JHAvatarAggregation"
  s.license          = 'MIT'
  s.author           = { "caojianhua" => "caojianhua1741@gmail.com" }
  s.source           = { :git => "https://github.com/caojianhua1741/JHAvatarAggregation.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'JHAvatarAggregation' => ['Pod/Assets/*.png']
  }

  s.dependency 'SDWebImage', '~> 3.7.1'
end
