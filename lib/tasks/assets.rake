# Ensure JavaScript assets are built before Rails asset precompilation
Rake::Task["assets:precompile"].enhance(["javascript:build"])
