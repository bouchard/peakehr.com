namespace :analyzer do
  desc "Run all analysis suites"
  task :all => [ :rails_best_practices ] do
  end

  desc "Run rails_best_practices and inform about found issues"
  task :rails_best_practices do
    require 'rails_best_practices'
    puts 'Running rails_best_practices and inform about found issues'
    app_root = Rake.application.original_dir
    output_file = File.join(app_root, 'tmp', 'rails_best_practices.html')
    analyzer = RailsBestPractices::Analyzer.new(app_root, {
      'format' => 'html',
      'with-textmate' => true,
      'output-file' => output_file
    })
    analyzer.analyze
    analyzer.output
    `open #{output_file}`
    fail "found bad practices" if analyzer.runner.errors.size > 0
  end
end