require "octokit"

class Issue < Thor
  desc "create TITLE [BODY]", "Create an issue for a repository"
  def create(title, body="")
    Sekaowa.github_auth
    p Octokit.create_issue(options[:repo], title, body)
  end

  desc "list", "List issues"
  def list
    p Octokit.list_issues(options[:repo])
  end
end

class Commit < Thor
  desc "list", "List commits"
  def list
    p Octokit.commits(options[:repo])
  end

  desc "create", "Create a commit"
  def create(msg, tree)
    Sekaowa.github_auth
    p Octokit.create_commit(options[:repo], msg, tree)
  rescue ::Octokit::NotFound => e
    puts "something go wrong. #{e}"
  rescue ::Octokit::UnprocessableEntity => e
    puts "Bad commit: #{e}"
  end
end

class Sekaowa < Thor
  class_option :repo, aliases:'-g', default:"melborne/sekaowa", desc:'target repository'
  class_option :revision, aliases:'-r', default:'master', desc:'target revision'
  # class_option :path, aliases:'-p', default:"site", desc:'target file path'
  class_option :username, desc:'github username'
  class_option :password, desc:'github password'

  desc "issue SUBCOMMAND ...ARGS", "manage set of issue tasks"
  subcommand "issue", Issue

  desc "commit SUBCOMMAND ...ARGS", "manage set of commit tasks"
  subcommand "commit", Commit

  no_tasks do
    def self.github_auth(username='melborne', password='Tram32tram')
      Octokit.configure do |c|
        c.login = username
        c.password = password
      end
      Octokit.user
    rescue ::Octokit::Unauthorized
      puts "Bad Credentials"
      exit(1)
    end
  end
end
