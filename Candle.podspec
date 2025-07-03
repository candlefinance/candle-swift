require "json"

versionSuffix = ""

Pod::Spec.new do |s|
  s.name         = "Candle"
  s.version      = "3.0.319" + versionSuffix
  s.summary      = "The Candle Swift SDK is a simple & secure way for developers to connect external services to LLMs, agents, and apps."
  s.homepage     = "https://docs.candle.fi/quick-start"
  s.license      = "Private"
  s.authors      = "Candle Finance Inc."

  s.platforms    = { :ios => '17.0' }
  s.source       = { :git => 'https://github.com/candlefinance/candle-swift.git', :tag => s.version }

  s.vendored_frameworks = Dir['XCFrameworks/*.xcframework']
end
