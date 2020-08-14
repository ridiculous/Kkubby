namespace :version do
  desc 'Bump version patch level'
  task patch: :environment do
    version_manager = VersionManager.new
    version_manager.write(version_manager.patch_bump)
  end

  namespace :patch do
    desc 'Rollback one patch level'
    task down: :environment do
      version_manager = VersionManager.new
      version_manager.write(version_manager.patch_bump(-1))
    end
  end

  desc 'Bump minor version'
  task minor: :environment do
    version_manager = VersionManager.new
    version_manager.write(version_manager.minor_bump)
  end

  namespace :minor do
    desc 'Rollback one minor version'
    task down: :environment do
      version_manager = VersionManager.new
      version_manager.write(version_manager.minor_bump(-1))
    end
  end

  desc 'Bump major version'
  task major: :environment do
    version_manager = VersionManager.new
    version_manager.write(version_manager.major_bump)
  end

  namespace :major do
    desc 'Rollback one major version'
    task down: :environment do
      version_manager = VersionManager.new
      version_manager.write(version_manager.major_bump(-1))
    end
  end
end

task version: :environment do
  puts VersionManager.new.current
end
