Pod::Spec.new do |s|
  s.name     = 'VONetworking'
  s.ios.deployment_target = "9.0"
  s.version  = '1.0.5'
  s.license = "Copyright (c) 2018年 Gavin. All rights reserved."
  s.homepage = 'https://github.com/feidaoGavin/VONetworking.git'
  s.summary  = 'VONetworking基于AFNetworking网络库，实现业务自定义'
  s.author   = 'heguangzhong2009@gmail.com'
  s.source   = { 
    :git => 'https://github.com/feidaoGavin/VONetworking.git', 
    :tag => s.version.to_s
  }
  s.requires_arc  = true
  s.source_files  = 'VONetworking', 'VONetworking/**/*.{h,m}'

  s.dependency 'VOToleranceTool', '0.0.2'
  s.dependency 'AFNetworking', '3.1.0'

  s.dependency 'VOBaseViewController', '1.0.2'
  s.dependency 'MBProgressHUD', '1.1.0'

  s.dependency 'VOJSONModel', '0.0.1'
  s.dependency 'GTSDK', '2.0.0.0'
  s.prefix_header_file = 'VONetworking/VONetworking-Prefix.pch'
end
