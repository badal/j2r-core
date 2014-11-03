namespace :metrics do

  SRC = File.dirname(__FILE__)
  METRICS = File.join(SRC, 'metrics')

  desc 'Run flog'
  task :flog do
    system 'flog -m -c -d -g lib/**/*.rb> metrics\flog.txt'
    puts `wc metrics/flog.txt`
  end

  desc 'Run flay'
  task :flay do
    system 'flay lib/**/*.rb > metrics\flay.txt'
    puts `wc metrics/flay.txt`
  end

  desc 'Run reek'
  task :reek do
    system 'reek lib/**/*.rb > metrics\reek.txt'
    puts `wc metrics/reek.txt`
  end

  desc 'Run churn'
  task :churn do
    system 'churn > metrics\churn.txt'
    puts `wc metrics/churn.txt`
  end

  desc 'Rubocop'
  task :rubocop do
    system 'rubocop lib/**/*.rb > metrics\rubocop_lib.txt'
    system 'rubocop test/**/*.rb > metrics\rubocop_test.txt'
    puts `wc metrics/rubocop_lib.txt`
    puts `wc metrics/rubocop_test.txt`
  end

  desc 'Flog, flay, reek, saikuro'
  task all_checks: [:flog, :flay, :reek, :saikuro]

  desc 'Flog with scores, flay, reek, saikuro'
  task all_checks_with_scores: [:flog_scores, :flay, :reek, :saikuro]

  desc 'Run saikuro'
  task :saikuro do
    puts 'saikuro'
    Dir.chdir(SRC)
    system 'saikuro -c -t -i lib lib/**/* -y 0 -w 11 -e 16 -o metrics/saikuro/ 2>&1'
  end

  desc 'Run flog and insert scores'
  task flog_scores: [:flog, :insert_scores]

  task :insert_scores do
    puts 'scores'
    REGEXP = Regexp.new('(\d+\.\d):\s+(\S+)\s+([^:]+):(\d+)')
    PREFIX = /^(\s+)/
    FLOG_FILE = File.join(METRICS, 'flog.txt')
    EXCLUDED = /initialize|add_menu/
    LIMIT = 25

    def get_parameters(str)
      _, score, method, name, line = *REGEXP.match(str)
      return name, line.to_i - 1, score unless EXCLUDED === method
    end

    def get_all_scores(limit)
      hash = Hash.new
      IO.readlines(FLOG_FILE).each do |line|
        name, number, score = *get_parameters(line)
        hash[name] ||= []
        hash[name] << [number, score] if name && score.to_i >= limit
      end
      hash.delete_if { |name, array| name.nil? || array.empty? }
    end

    def insert_flog_scores(name, list)
      file = File.join(SRC, name)
      array = IO.readlines(file)
      modified = false
      list.each do |number, score|
        match = PREFIX.match(array[number])
        next unless match
        comment = match[1] + '# FLOG: ' + score
        previous = number - 1
        previous_line = array[previous].chomp
        if previous_line == comment
          next
        elsif previous_line =~ /FLOG:/
          puts "#{name}, #{number}, old : " + previous_line.strip + ' - new :' + comment.strip
          array[previous] = comment
          modified = true
        else
          puts "#{name}, #{number}, new :" + comment.strip
          array[number, 0] = comment
          modified = true
        end
      end
      File.open(file, 'w') { |f| array.each { |line| f.puts(line) } } if modified
    end

    def insert_all_scores(limit)
      get_all_scores(limit).each { |name, list| insert_flog_scores(name, list) }
    end

    insert_all_scores(LIMIT)
  end

end
