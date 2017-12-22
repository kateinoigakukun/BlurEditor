Pod::Spec.new do |s|

  s.name         = "BlurEditor"
  s.version      = "1.0.1"
  s.summary      = "This provides image editor for drawing blur effects."

  s.description  = <<-DESC
                        - Drawing blur effects
                        - Erasing effects
                        - Export canvas
                   DESC

  s.homepage     = "https://github.com/kateinoigakukun/BlurEditor"
  s.screenshots  = "https://github.com/kateinoigakukun/BlurEditor/raw/v1.0.1/assets/demo.gif"

  s.license      = "MIT"

  s.author             = { "Yuta Saito" => "kateinoigakukun@gmail.com" }
  s.social_media_url   = "http://twitter.com/kateinoigakukun"

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/kateinoigakukun/BlurEditor.git", :tag => "v#{s.version}" }


  s.source_files  = "BlurEditor/**/*.swift"

end
