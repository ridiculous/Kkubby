class VersionManager
  attr_writer :file_contents

  def initialize(file_contents = nil)
    @file_contents = file_contents
  end

  def file_contents
    @file_contents ||= File.read(Rails.root.join('config', 'application.rb'))
  end

  def write(contents)
    log '* Bumping version ...'
    File.open(Rails.root.join('config', 'application.rb'), 'wb') { |f| f.puts contents }
    `git add config/application.rb`
    log "* Commiting version #{current}"
    `git commit -m "version #{current}"`
    `git tag -a v#{current} -m ""`
    log '* Done'
  rescue => e
    log "! #{e.class}: #{e.message}\n #{e.backtrace}"
  end

  def current
    if file_contents =~ /version\s=\s'(\d+\.\d+\.\d+)/
      $1
    else
      fail 'Failed to find current version'
    end
  end

  def major_bump(increment_count = 1)
    if file_contents =~ /version\s=\s'(\d+)\.\d+\.\d+/
      major = $1.to_i
      file_contents.sub! /(version\s=\s')(\d+)\.\d+\.\d+/, '\1' + (major + increment_count).to_s + '.0.0'
    else
      fail 'Failed to find major version in the file contents'
    end
  end

  def minor_bump(increment_count = 1)
    if file_contents =~ /version\s=\s'\d+\.(\d+)\.\d+/
      minor = $1.to_i
      file_contents.sub! /(version\s=\s'\d+\.)(\d+).\d+/, '\1' + (minor + increment_count).to_s + '.0'
    else
      fail 'Failed to find minor version in the file contents'
    end
  end

  def patch_bump(increment_count = 1)
    if file_contents =~ /version\s=\s'\d+\.\d+\.(\d+)/
      patch_level = $1.to_i
      file_contents.sub! /(version\s=\s'\d+\.\d+\.)(\d+)/, '\1' + (patch_level + increment_count).to_s
    else
      fail 'Failed to find patch level in the file contents'
    end
  end

  def log(msg = nil)
    puts %Q(  #{msg})
  end
end
