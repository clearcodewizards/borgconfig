require "base64"

class CubeFile
  def self.all
    files_to_base64_hash
  end

  private

  def self.files_to_base64_hash
    files = {}

    Dir.glob(Rails.root.join("storage/cube_files", "*.rb")).each do |file_path|
      next unless File.file?(file_path) # skip directories

      filename = File.basename(file_path)
      content = File.binread(file_path)
      encoded = Base64.strict_encode64(content)

      files[filename] = encoded
    end

    files
  end
end
