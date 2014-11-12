require 'rss'
require 'fileutils'

module Rebuild
  class Download
    def initialize
      @home = Dir.home
    end
    
    def download
      create_directory
      parse_rss.items.each do |item|
	if has_episode?(item.title)
	  Dir.chdir(episode_directory) do
	    if File.exist?(regular_filename(title: item.title))
	      has_file_message(item.title)
	      next
	    end
	    curl(item.title, item.enclosure.url)
	  end
	else
	  Dir.chdir(aftershow_directory) do
	    if File.exist?(regular_filename(title: item.title))
	      has_file_message(item.title)
	      next
	    end
	    curl(item.title, item.enclosure.url)
	  end
	end
      end
    end

    private
    def download_directory
      File.join(@home, "rebuild")
    end

    def episode_directory
      File.join(download_directory, "episode")
    end

    def aftershow_directory
      File.join(download_directory, "aftershow")
    end

    def has_episode?(title)
      unless /\AAftershow/ === title
	true
      else
	false
      end
    end

    def has_file_message(file)
      puts "#{file}は、存在します。"
    end

    def parse_rss
      @rss ||= RSS::Parser.parse("http://feeds.rebuild.fm/rebuildfm")
    end
    
    def regular_filename(title: title)
      "#{title.delete("/")}.mp3"
    end

    def curl(file, url)
      puts "今、ダウンロードしているのは -> #{file} です。"
      system("curl",
	     "--location",
	     "--output",
	     regular_filename(title: file),
	     url)
    end

    def create_directory
      FileUtils.mkdir_p(aftershow_directory) unless Dir.exist?(aftershow_directory)
      FileUtils.mkdir_p(episode_directory) unless Dir.exist?(episode_directory)
    end
  end
end
