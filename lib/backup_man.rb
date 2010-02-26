$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

def require_relative(relative_feature)
  c = caller.first
  fail "Can't parse #{c}" unless c.rindex(/:\d+(:in `.*')?$/)
  file = $`
  if /\A\((.*)\)/ =~ file # eval, etc.
    raise LoadError, "require_relative is called in #{$1}"
  end
  absolute = File.expand_path(relative_feature,
  File.dirname(file))
  require absolute
end

module BackupMan
  ::Version = File.read('VERSION')    # used by optparse
end
