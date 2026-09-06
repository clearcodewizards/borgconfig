require "base64"

class DirectiveFile
  def self.all
    files_to_base64_hash
  end

  def self.files_to_base64_hash
    files = {}

    Rails.root.glob("lib/directives/*.rb").each do |file_path|
      next unless File.file?(file_path) # skip directories

      filename = File.basename(file_path)
      content = File.binread(file_path)
      encoded = Base64.strict_encode64(content)

      files[filename] = encoded
    end

    files
  end

  def self.allowed?(user, filename)
    return false unless all.key?(filename)

    load Rails.root.join("lib/directives", filename)
    klass = Object.const_get(klass_name(filename))
    directive_role = User.roles[klass.role]
    return false unless directive_role

    User.roles[user.role] >= directive_role
  end

  def self.klass_name(filename)
    klass = filename.split(".rb").first
    klass.split("_").map(&:capitalize).join
  end
end
