#
#  Be sure to run `pod spec lint DNVFontPicker.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "DNVFontPicker"
  s.version      = "0.1"
  s.summary      = "DNVFontPicker is an iOS input view intended to assign font and character attributes."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
-
                   DESC

  s.homepage     = "https://github.com/DnV1eX/DNVFontPicker"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "Apache License, Version 2.0"

  s.author             = { "Alexey Demin" => "dnv1ex@ya.ru" }
  s.social_media_url   = "https://twitter.com/dnv1ex"

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/DnV1eX/DNVFontPicker.git", :tag => "#{s.version}" }

  s.source_files = "DNVFontPicker/DNVFontPickerView.swift"

  s.requires_arc = true

end
