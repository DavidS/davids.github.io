#!/usr/bin/env ruby

require "open3"

pushed_refs = $stdin.readlines

output, status = Open3.capture2e("git annex post-receive", stdin_data: pushed_refs.join("\n"))

puts output

Dir.chdir("#{ENV['SRV_DIR']}/git")
# # redirect bundle config to protect read-only homes
# ENV['BUNDLE_APP_CONFIG'] = "#{ENV['SRV_DIR']}/gems"
system("bundle config set --local path #{ENV['SRV_DIR']}/gems")
system("bundle install")
system("JEKYLL_ENV=production bundle exec jekyll build --strict --trace --destination #{ENV['SRV_DIR']}/site --verbose --incremental")
