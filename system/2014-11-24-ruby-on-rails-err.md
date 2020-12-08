---
title: ruby on rails 报错解决
date: 2014-11-24
tags:
- ruby
categories:
 - System
---




ruby on rails 报错解决

```bash
/usr/local/ruby/lib/ruby/gems/2.1.0/gems/execjs-2.2.2/lib/execjs/runtimes.rb:51:in `autodetect': Could not find a JavaScript runtime. See https://github.com/sstephenson/execjs for a list of available runtimes. (ExecJS::RuntimeUnavailable)
        from /usr/local/ruby/lib/ruby/gems/2.1.0/gems/execjs-2.2.2/lib/execjs.rb:5:in `<module:ExecJS>'
        from /usr/local/ruby/lib/ruby/gems/2.1.0/gems/execjs-2.2.2/lib/execjs.rb:4:in `<top (required)>'
        from /usr/local/ruby/lib/ruby/2.1.0/rubygems/core_ext/kernel_require.rb:55:in `require'
        from /usr/local/ruby/lib/ruby/2.1.0/rubygems/core_ext/kernel_require.rb:55:in `require'
        from /usr/local/ruby/lib/ruby/gems/2.1.0/gems/coffee-script-2.3.0/lib/coffee_script.rb:1:in `<top (required)>'
        from /usr/local/ruby/lib/ruby/2.1.0/rubygems/core_ext/kernel_require.rb:55:in `require'
        from /usr/local/ruby/lib/ruby/2.1.0/rubygems/core_ext/kernel_require.rb:55:in `require'
        from /usr/local/ruby/lib/ruby/gems/2.1.0/gems/coffee-script-2.3.0/lib/coffee-script.rb:1:in `<top (required)>'
        from /usr/local/ruby/lib/ruby/2.1.0/rubygems/core_ext/kernel_require.rb:55:in `require'
        from /usr/local/ruby/lib/ruby/2.1.0/rubygems/core_ext/kernel_require.rb:55:in `require'
        from /usr/local/ruby/lib/ruby/gems/2.1.0/gems/jekyll-coffeescript-1.0.1/lib/jekyll-coffeescript.rb:2:in `<top (required)>'
        from /usr/local/ruby/lib/ruby/2.1.0/rubygems/core_ext/kernel_require.rb:55:in `require'
        from /usr/local/ruby/lib/ruby/2.1.0/rubygems/core_ext/kernel_require.rb:55:in `require'
        from /usr/local/ruby/lib/ruby/gems/2.1.0/gems/jekyll-2.5.2/lib/jekyll/deprecator.rb:46:in `block in gracefully_require'
        from /usr/local/ruby/lib/ruby/gems/2.1.0/gems/jekyll-2.5.2/lib/jekyll/deprecator.rb:44:in `each'
        from /usr/local/ruby/lib/ruby/gems/2.1.0/gems/jekyll-2.5.2/lib/jekyll/deprecator.rb:44:in `gracefully_require'
        from /usr/local/ruby/lib/ruby/gems/2.1.0/gems/jekyll-2.5.2/lib/jekyll.rb:166:in `<top (required)>'
        from /usr/local/ruby/lib/ruby/2.1.0/rubygems/core_ext/kernel_require.rb:55:in `require'
        from /usr/local/ruby/lib/ruby/2.1.0/rubygems/core_ext/kernel_require.rb:55:in `require'
        from /usr/local/ruby/lib/ruby/gems/2.1.0/gems/jekyll-2.5.2/bin/jekyll:6:in `<top (required)>'
        from /usr/local/ruby/bin/jekyll:23:in `load'
        from /usr/local/ruby/bin/jekyll:23:in `<main>'
```

解决 

    yum -y install nodejs