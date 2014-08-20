Pod::Spec.new do |s|

  # due to https://github.com/CocoaPods/CocoaPods/issues/1001
  def s.PMKiOS; "6.0"; end
  # due to ARC requirement (5.0)
  def s.PMKOSX; "10.7"; end

  s.name = "PromiseKit"
  s.version = "0.9.16"
  s.source = { :git => "https://github.com/mxcl/#{s.name}.git", :tag => s.version }
  s.license = 'MIT'
  s.summary = 'A delightful Promises implementation for iOS and OS X.'
  s.homepage = 'http://promisekit.org'
  s.social_media_url = 'https://twitter.com/mxcl'
  s.authors  = { 'Max Howell' => 'mxcl@me.com' }
  s.documentation_url = 'http://promisekit.org/api/'
  s.default_subspecs = 'NSURLConnection', 'NSNotificationCenter',
                       'UIActionSheet', 'UIAlertView', 'UIViewController', 'UIView',
                       'Pause', 'When', 'Until'
  s.requires_arc = true

  def s.mksubspec name
    prefix = name[0..1]
    framework = case prefix
      when 'UI' then 'UIKit'
      when 'CL' then 'CoreLocation'
      when 'MK' then 'MapKit'
      when 'AV' then 'AVFoundation'
      when 'AC' then 'Accounts'
      when 'SL' then 'Social'
      when 'SK' then 'StoreKit'
      when 'CK' then 'CloudKit'
      else 'Foundation'
    end

    subspec(name) do |ss|

      pmk_max = Proc.new do |a, b|
        split = Proc.new{ |f| f.split('.').map{|s| s.to_i } }
        max = [split.call(a), split.call(a)].max
        max.join(".")
      end

      ss.dependency 'PromiseKit/Promise'
      ss.preserve_paths = 'objc/PromiseKit'

      yield(ss)

      if ss.deployment_target(:ios).nil?
        ss.osx.deployment_target = pmk_max.call(ss.deployment_target(:osx), self.PMKOSX)
        ss = ss.osx
      elsif ss.deployment_target(:osx).nil?
        ss.ios.deployment_target = pmk_max.call(ss.deployment_target(:ios), self.PMKOSX)
        ss = ss.ios
      else
        ss.ios.deployment_target = pmk_max.call(ss.deployment_target(:ios), self.PMKiOS)
        ss.osx.deployment_target = pmk_max.call(ss.deployment_target(:osx), self.PMKOSX)
      end

      ss.framework = framework
      ss.source_files = (ss.source_files rescue []) + ["objc/#{name}+PromiseKit.h", "objc/#{name}+PromiseKit.m", "objc/deprecated/PromiseKit+#{framework}.h"]

      ss.xcconfig = { "GCC_PREPROCESSOR_DEFINITIONS" => "$(inherited) PMK_#{name.upcase}=1" }
    end
  end

  s.subspec 'Promise' do |ss|
    ss.ios.deployment_target = s.PMKiOS
    ss.osx.deployment_target = s.PMKOSX
    ss.source_files = 'objc/PromiseKit.h', 'objc/PMKPromise.m', 'objc/PromiseKit/Promise.h', 'objc/PromiseKit/fwd.h'
    ss.preserve_paths = 'objc/PromiseKit', 'objc/Private'
    ss.frameworks = 'Foundation'
  end

  %w{Pause Until When}.each do |name|
    s.subspec(name) do |ss|
      ss.source_files = "objc/PMKPromise+#{name}.m", "objc/PromiseKit/Promise+#{name}.h"
      ss.xcconfig = { "GCC_PREPROCESSOR_DEFINITIONS" => "$(inherited) PMK_#{name.upcase}=1" }
      ss.preserve_paths = 'objc/PromiseKit'
      ss.ios.deployment_target = s.PMKiOS
      ss.osx.deployment_target = s.PMKOSX
      ss.dependency 'PromiseKit/When' if name == 'Until'
      ss.dependency 'PromiseKit/Promise'
    end
  end

  s.subspec 'base' do |ss|   # deprecated
    ss.dependency 'PromiseKit/Promise'
    ss.dependency 'PromiseKit/When'
    ss.dependency 'PromiseKit/Until'
  end

  s.mksubspec 'ACAccountStore' do |ss|
    ss.ios.deployment_target = '6.0'
    ss.osx.deployment_target = '10.8'
  end
  s.mksubspec 'AVAudioSession' do |ss|
    ss.ios.deployment_target = '7.0'
  end
  s.mksubspec 'CLGeocoder' do |ss|
    ss.ios.deployment_target = '5.0'
    ss.osx.deployment_target = '10.8'
  end
  s.mksubspec 'CKContainer' do |ss|
    ss.ios.deployment_target = '8.0'
    ss.osx.deployment_target = '10.10'
  end
  s.mksubspec 'CKDatabase' do |ss|
    ss.ios.deployment_target = '8.0'
    ss.osx.deployment_target = '10.10'
  end
  s.mksubspec 'CLLocationManager' do |ss|
    ss.ios.deployment_target = '2.0'
    ss.osx.deployment_target = '10.6'
  end
  s.mksubspec 'MKDirections' do |ss|
    ss.ios.deployment_target = '7.0'
    ss.osx.deployment_target = '10.9'
  end
  s.mksubspec 'MKMapSnapshotter' do |ss|
    ss.ios.deployment_target = '7.0'
    ss.osx.deployment_target = '10.9'
  end
  s.mksubspec 'NSNotificationCenter' do |ss|
    ss.ios.deployment_target = '4.0'
    ss.osx.deployment_target = '10.6'
  end
  s.mksubspec 'NSTask' do |ss|
    ss.osx.deployment_target = '10.0'
  end
  s.mksubspec 'NSURLConnection' do |ss|
    ss.dependency "OMGHTTPURLRQ"
    ss.ios.deployment_target = '5.0'
    ss.osx.deployment_target = '10.7'
  end
  s.mksubspec 'SKProductsRequest' do |ss|
    ss.ios.deployment_target = '3.0'
    ss.osx.deployment_target = '10.7'
  end
  s.mksubspec 'SLRequest' do |ss|
    ss.ios.deployment_target = '6.0'
    ss.osx.deployment_target = '10.8'
  end
  s.mksubspec 'UIActionSheet' do |ss|
    ss.ios.deployment_target = '2.0'
  end
  s.mksubspec 'UIAlertView' do |ss|
    ss.ios.deployment_target = '2.0'
  end
  s.mksubspec 'UIView' do |ss|
    ss.ios.source_files = 'objc/deprecated/PromiseKit+UIAnimation.h'
    ss.ios.deployment_target = '4.0'
  end
  s.mksubspec 'UIViewController' do |ss|
    ss.ios.deployment_target = '5.0'
    ss.ios.weak_frameworks = 'AssetsLibrary'
  end

  s.subspec 'Accounts' do |ss|
    ss.dependency 'PromiseKit/ACAccountStore'
  end
  s.subspec 'AVFoundation' do |ss|
    ss.dependency 'PromiseKit/AVAudioSession'
  end
  s.subspec 'CloudKit' do |ss|
    ss.dependency 'PromiseKit/CKContainer'
    ss.dependency 'PromiseKit/CKDatabase'
  end
  s.subspec 'CoreLocation' do |ss|
    ss.dependency 'PromiseKit/CLGeocoder'
    ss.dependency 'PromiseKit/CLLocationManager'
  end
  s.subspec 'Foundation' do |ss|
    ss.dependency 'PromiseKit/NSNotificationCenter'
    ss.dependency 'PromiseKit/NSTask'
    ss.dependency 'PromiseKit/NSURLConnection'
  end
  s.subspec 'MapKit' do |ss|
    ss.dependency 'PromiseKit/MKDirections'
    ss.dependency 'PromiseKit/MKMapSnapshotter'
  end
  s.subspec 'Social' do |ss|
    ss.dependency 'PromiseKit/SLRequest'
  end
  s.subspec 'StoreKit' do |ss|
    ss.dependency 'PromiseKit/SKProductsRequest'
  end
  s.subspec 'UIKit' do |ss|
    ss.dependency 'PromiseKit/UIActionSheet'
    ss.dependency 'PromiseKit/UIAlertView'
    ss.dependency 'PromiseKit/UIView'
    ss.dependency 'PromiseKit/UIViewController'
  end

  s.subspec 'all' do |ss|
    ss.dependency 'PromiseKit/When'
    ss.dependency 'PromiseKit/Until'
    ss.dependency 'PromiseKit/Pause'

    ss.dependency 'PromiseKit/Accounts'
    ss.dependency 'PromiseKit/AVFoundation'
    ss.dependency 'PromiseKit/CloudKit'
    ss.dependency 'PromiseKit/CoreLocation'
    ss.dependency 'PromiseKit/Foundation'
    ss.dependency 'PromiseKit/MapKit'
    ss.dependency 'PromiseKit/Social'
    ss.dependency 'PromiseKit/StoreKit'
    ss.dependency 'PromiseKit/UIKit'
  end

end
