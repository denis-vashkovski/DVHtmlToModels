Pod::Spec.new do |s|
  s.name                = "DVHtmlToModels"
  s.version             = "0.1.4"
  s.summary             = "Parse html to models."
  s.homepage            = 'https://github.com/denis-vashkovski/DVHtmlToModels'
  s.license             = { :type => 'MIT', :file => 'LICENSE' }
  s.authors             = { 'Denis Vashkovski' => 'denis.vashkovski.vv@gmail.com' }
  s.source              = { :git => 'https://github.com/denis-vashkovski/DVHtmlToModels.git', :tag => s.version.to_s }
  s.platform            = :ios, "7.1"
  s.ios.source_files    = 'DVHtmlToModels/*.{h,m}'
  s.requires_arc        = true
end
