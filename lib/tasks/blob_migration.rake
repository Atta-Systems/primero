# frozen_string_literal: true

# This is done to reference ActiveStorage::Blob so service_configurations are available in dev mode
# https://github.com/rails/rails/issues/41636#issuecomment-792366847
Rails.application.config.to_prepare do
  ActiveStorage::Blob.present?
end

def download_from(from)
  configs = Rails.configuration.active_storage.service_configurations
  from_service = ActiveStorage::Service.configure from, configs

  ActiveStorage::Blob.service = from_service

  ActiveStorage::Blob.find_in_batches(batch_size: 50) do |batch|
    # Spawn a new process for each batch. This is a disgusting hack to avoid running out of memory.
    Process.fork do
      puts "Spawning process for batch #{batch.first.id} - #{batch.last.id}, size: #{batch.size}"
      batch.each do |blob|
        puts "Downloading blob #{blob.key}"
        file = File.new("/mnt/migrate/blobs/#{blob.key}", 'w')
        file.binmode
        file << blob.download
        file.close
      end
    end
    Process.waitall

  rescue ActiveStorage::FileNotFoundError
    puts "Rescued by FileNotFoundError. Key: #{blob.key}"
    next
  end
end

def upload_to(to)
  configs = Rails.configuration.active_storage.service_configurations
  to_service = ActiveStorage::Service.configure to, configs

  Dir.foreach('/tmp/blobs') do |filename|
    next if filename == '.' or filename == '..'

    puts "Uploading blob #{filename}"
    checksum = Digest::MD5.file("/tmp/blobs/#{filename}").base64digest
    file = File.open("/tmp/blobs/#{filename}", 'r')
    file.rewind
    file.binmode
    to_service.upload(filename, file, checksum: checksum)
    file.close
  rescue Errno::ENOENT
    puts "Rescued by Errno::ENOENT statement. Key: #{filename}"
    next
  rescue ActiveStorage::FileNotFoundError
    puts "Rescued by FileNotFoundError. Key: #{filename}"
    next
  end
end

def migrate(from, to)
  download_from(from)
  upload_to(to)
end

namespace :blobs do
  desc 'Migrate ActiveStorage files from one type of storage to another'
  task :migrate, %i[from to] => :environment do |_, args|
    if args.nil? || args[:from].nil? || args[:to].nil?
      puts 'Please provide source and destination'
      exit
    end
    migrate(args[:from], args[:to])
  end

  desc 'Download ActiveStorage files from given storage'
  task :download_from, %i[from] => :environment do |_, args|
    if args.nil? || args[:from].nil?
      puts 'Please provide source'
      exit
    end
    download_from(args[:from])
  end

  desc 'Upload ActiveStorage files to given storage'
  task :upload_to, %i[to] => :environment do |_, args|
    if args.nil? || args[:to].nil?
      puts 'Please provide destination'
      exit
    end
    upload_to(args[:to])
  end
end
