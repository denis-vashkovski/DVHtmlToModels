Pod::Spec.new do |s|
  s.name                = "DVHtmlToModels"
  s.version             = "0.0.1"
  s.summary             = "Parse html to models."
  s.homepage            = 'https://github.com/denis-vashkovski/DVHtmlToModels'
  s.license             = { :type => 'MIT', :file => 'LICENSE' }
  s.authors             = { 'Denis Vashkovski' => 'denis.vashkovski.vv@gmail.com' }
  s.platform            = :ios, "7.1"
  s.source              = { :git => 'https://github.com/denis-vashkovski/DVHtmlToModels.git', :tag => s.version.to_s }
  s.ios.source_files    = 'DVHtmlToModels/*.{h,m}'
  s.requires_arc        = true
  s.ios.dependency      'hpple', '~> 0.2'
end
